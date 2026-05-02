function cwt --description 'Bare cwt: cd to the worktree of claude running in a sibling seance pane (fzf fallback). cwt -d: delete current worktree if inside one, else fzf.'
    set -l mode default
    if test "$argv[1]" = -d
        set mode delete
        set -e argv[1]
    end

    if test "$mode" = delete
        set -l root (git rev-parse --show-toplevel 2>/dev/null)
        if test -z "$root"
            echo "not in a git repo" >&2
            return 1
        end
        set -l main_wt (git -C $root worktree list --porcelain | awk '/^worktree / { print substr($0, 10); exit }')

        if test "$root" != "$main_wt"
            set -l current_wt $root
            set -l current_branch (git -C $current_wt branch --show-current 2>/dev/null)
            read -P "remove current worktree $current_wt and branch $current_branch? [y/N] " ans
            switch $ans
                case y Y yes YES
                    cd $main_wt
                    or return 1
                    git -C $main_wt worktree remove $current_wt
                    or return 1
                    if test -n "$current_branch"
                        git -C $main_wt branch -D $current_branch 2>/dev/null
                        or echo "note: could not delete branch $current_branch" >&2
                    end
                    return 0
                case '*'
                    echo aborted
                    return 1
            end
        end

        set -l list (git -C $root worktree list --porcelain | awk '
            /^worktree / { path = substr($0, 10) }
            /^branch /   { br = substr($0, 19); printf "%-40s %s\n", br, path; br="" }
            /^detached/  { printf "%-40s %s\n", "(detached)", path }
        ')
        set list (printf '%s\n' $list | awk -v main="$main_wt" 'NF && $NF != main')
        if test (count $list) -eq 0
            echo "no removable worktrees" >&2
            return 1
        end
        set -l selection (printf '%s\n' $list | fzf --height=40% --reverse --header="delete worktree + branch" --prompt="cwt -d> ")
        if test -z "$selection"
            return 1
        end
        set -l dir (printf '%s' $selection | awk '{print $NF}')
        set -l branch (printf '%s' $selection | awk '{print $1}')
        if test -z "$dir"
            return 1
        end
        read -P "remove worktree $dir and branch $branch? [y/N] " ans
        switch $ans
            case y Y yes YES
            case '*'
                echo aborted
                return 1
        end
        if test "$PWD" = "$dir"; or string match -q "$dir/*" $PWD
            cd $main_wt
            or return 1
        end
        git -C $main_wt worktree remove $dir
        or return 1
        if test -n "$branch"; and test "$branch" != "(detached)"
            git -C $main_wt branch -D $branch 2>/dev/null
            or echo "note: could not delete branch $branch" >&2
        end
        return 0
    end

    if command -q seance; and command -q jq
        set -l info (seance ctl --json identify 2>/dev/null)
        set -l ws (echo $info | jq -r '.workspace_id // empty')
        set -l my_id (echo $info | jq -r '.surface_id // empty')
        set -l seance_pid (pgrep -x seance 2>/dev/null | head -1)
        if test -n "$ws"; and test -n "$my_id"; and test -n "$seance_pid"
            set -l sibling_ids (seance ctl --json list-surfaces --workspace $ws 2>/dev/null | jq -r --argjson me $my_id '.surfaces[] | select(.id != $me) | .id')
            for sid in $sibling_ids
                set -l target_fish
                for fpid in (pgrep -P $seance_pid -x fish 2>/dev/null)
                    set -l panel_id (tr '\0' '\n' < /proc/$fpid/environ 2>/dev/null | grep '^SEANCE_PANEL_ID=' | cut -d= -f2)
                    if test "$panel_id" = "$sid"
                        set target_fish $fpid
                        break
                    end
                end
                test -n "$target_fish"; or continue
                set -l queue (pgrep -P $target_fish 2>/dev/null)
                while test (count $queue) -gt 0
                    set -l p $queue[1]
                    set -e queue[1]
                    set -l comm (cat /proc/$p/comm 2>/dev/null)
                    if test "$comm" = claude
                        set -l ccwd (readlink /proc/$p/cwd 2>/dev/null)
                        if test -n "$ccwd"
                            seance ctl rename-workspace $ws (basename $ccwd) >/dev/null 2>&1
                            cd $ccwd
                            echo "→ $ccwd"
                            return 0
                        end
                    end
                    for c in (pgrep -P $p 2>/dev/null)
                        set -a queue $c
                    end
                end
            end
        end
    end

    set -l root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$root"
        echo "no claude found in this seance workspace, and not in a git repo for fzf fallback" >&2
        return 1
    end
    set -l list (git -C $root worktree list --porcelain | awk '
        /^worktree / { path = substr($0, 10) }
        /^branch /   { br = substr($0, 19); printf "%-40s %s\n", br, path; br="" }
        /^detached/  { printf "%-40s %s\n", "(detached)", path }
    ')
    set -l selection (printf '%s\n' $list | fzf --height=40% --reverse --header=worktrees --prompt="cwt> ")
    if test -z "$selection"
        return 1
    end
    set -l dir (printf '%s' $selection | awk '{print $NF}')
    if test -n "$dir"
        cd $dir
    end
end

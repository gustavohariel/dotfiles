function cc --description 'claude, then cd to the worktree it left a breadcrumb in'
    set -l breadcrumb $HOME/.cache/claude-last-worktree
    rm -f $breadcrumb
    claude $argv
    if test -s $breadcrumb
        set -l wt_path (cat $breadcrumb)
        rm -f $breadcrumb
        if test -d "$wt_path"
            cd $wt_path
        end
    end
end

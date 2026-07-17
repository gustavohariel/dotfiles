---
name: tea-cli
description: "Use the Gitea `tea` CLI to manage Gitea logins, repositories, issues, pull requests, review comments, labels, milestones, releases, Actions workflows/runs/secrets/variables, notifications, and authenticated API requests. Use this skill whenever the user mentions tea, Gitea CLI, Gitea PRs/issues, review comments or thread resolution, Gitea Actions, or repo operations on Gitea. Prefer this over GitHub tooling for this repo because le-ko uses Gitea, not GitHub."
---

# Gitea CLI (`tea`)

Use this skill when the user wants to interact with Gitea from the terminal. In this repo, prefer `tea` over GitHub tooling for PRs, issues, review comments, Actions, releases, and repository metadata.

`tea` reads repository context from the current working directory when possible. It works best when local branches are already pushed to a remote; commands like PR creation assume published git state.

## Quick Reference

- `tea logins list` - List configured Gitea accounts.
- `tea logins add` - Add a Gitea login interactively or via token.
- `tea whoami` - Show the current logged-in user.
- `tea repo list` - List repositories available to the current account.
- `tea issue list` - List issues in the current repo.
- `tea issue <index>` - Show one issue in detail.
- `tea pr list` - List pull requests in the current repo.
- `tea pr <index>` - Show one pull request in detail.
- `tea pr checkout <index> --branch` - Check out a PR locally.
- `tea pr create --title "..." --description "..."` - Create a PR.
- `tea pr review-comments <index>` - List review comments on a PR.
- `tea pr resolve <comment-id>` - Resolve a review comment thread.
- `tea comment <issue-or-pr-index> "message"` - Add an issue/PR comment.
- `tea actions runs list` - List Gitea Actions workflow runs.
- `tea api '<endpoint>'` - Make an authenticated Gitea API request.

## Output Formats

Most list/view commands support:

```bash
--output simple
--output table
--output csv
--output tsv
--output yaml
--output json
```

Use `--output json` for scripts and automation. Use `--fields` to keep machine output narrow and stable when the command supports it.

Common context flags:

- `--repo <owner>/<repo>` / `-r <owner>/<repo>` - Override repository context.
- `--remote <name>` / `-R <name>` - Discover Gitea login from a specific git remote.
- `--login <name>` / `-l <name>` - Use a specific configured login.
- `--debug` / `--vvv` - Debug request behavior.

## Authentication

```bash
tea logins list
tea logins default
tea logins add --name <name> --url <gitea-url> --token <token>
tea logins add --name <name> --url <gitea-url> --oauth
tea logins default <name>
tea logout <name>
tea whoami
```

`tea logins add` can also read:

- `GITEA_SERVER_URL`
- `GITEA_SERVER_TOKEN`
- `GITEA_SERVER_USER`
- `GITEA_SERVER_PASSWORD`
- `GITEA_SERVER_OTP`
- `GITEA_SCOPES`

Do not print tokens or commit files containing them. For one-off scripts, prefer environment variables supplied by the shell/CI secret store.

## Repositories

```bash
tea repo list --limit 30 --output json
tea repo list --owner <org-or-user>
tea repo search <query>
tea repo create <name>
tea repo fork <owner>/<repo>
tea repo edit <owner>/<repo>
tea repo delete <owner>/<repo>
tea open
```

Useful `repo list` fields:

```bash
tea repo list --fields owner,name,type,ssh,url,updated,permission --output json
```

Repository operations default to the current working directory's repo when possible. Pass `--repo <owner>/<repo>` when running from another directory or when context could be ambiguous.

## Issues

```bash
tea issue list --state open --limit 30
tea issue list --state all --keyword "search text" --output json
tea issue <index> --comments
tea issue create --title "Title" --description "Body"
tea issue edit <index> --add-labels bug,high-priority
tea issue edit <index> --remove-labels needs-info
tea issue close <index>
tea issue reopen <index>
tea comment <index> "Comment body"
```

Useful filters:

```bash
--state all|open|closed
--kind issues|pulls|all
--keyword <text>
--labels label-a,label-b
--milestones milestone-a
--author <user>
--assignee <user>
--mentions <user>
--from <date>
--until <date>
```

Useful fields:

```bash
tea issue list --fields index,state,author,url,title,labels,comments,updated --output json
```

## Pull Requests

```bash
tea pr list --state open --limit 30
tea pr list --state all --output json
tea pr <index> --comments
tea pr checkout <index> --branch
tea pr create --head <branch> --base <base> --title "Title" --description "Body"
tea pr edit <index> --title "New title" --description "New body"
tea pr close <index>
tea pr reopen <index>
tea pr merge <index> --style merge|rebase|squash|rebase-merge
```

PR creation notes:

- Push the local branch before creating the PR.
- `--head` defaults to the current branch.
- Use `<user>:<branch>` for PRs from a fork.
- `--base` defaults to the repo default branch.
- Use `--allow-maintainer-edits` / `--edits` when maintainers should be allowed to push to the PR branch.

Useful PR fields:

```bash
tea pr list --fields index,state,author,url,title,base,head,mergeable,ci,updated --output json
```

## PR Reviews and Review Comments

```bash
tea pr review <index>
tea pr approve <index> "Looks good"
tea pr reject <index> "Reason for requesting changes"
tea pr review-comments <index> --output json
tea pr review-comments <index> --fields id,path,line,body,reviewer,resolver,url --output json
tea pr resolve <comment-id>
tea pr unresolve <comment-id>
```

Use `review-comments` before resolving or unresolving so you act on the exact comment ID. Do not infer comment IDs from line numbers or URLs when `tea` can list them.

## Labels and Milestones

```bash
tea labels list --output json
tea labels create <name> --color <hex>
tea labels update <name>
tea labels delete <name>

tea milestones list --state open --output json
tea milestones create <name>
tea milestones close <name>
tea milestones reopen <name>
tea milestones delete <name>
tea milestones issues <name>
```

## Releases

```bash
tea releases list --output json
tea releases create --help
tea releases edit <tag>
tea releases delete <tag>
tea releases assets <command>
```

Run subcommand help before mutating releases or assets; release commands vary by Gitea version and server permissions.

## Gitea Actions

```bash
tea actions runs list --repo <owner>/<repo> --output json
tea actions runs view <run-id> --repo <owner>/<repo>
tea actions runs logs <run-id> --repo <owner>/<repo>
tea actions runs cancel <run-id> --repo <owner>/<repo>

tea actions workflows list --repo <owner>/<repo> --output json
tea actions workflows view <workflow> --repo <owner>/<repo>
tea actions workflows dispatch <workflow> --repo <owner>/<repo>
tea actions workflows enable <workflow> --repo <owner>/<repo>
tea actions workflows disable <workflow> --repo <owner>/<repo>

tea actions secrets list --repo <owner>/<repo>
tea actions secrets create <name> --repo <owner>/<repo>
tea actions secrets delete <name> --repo <owner>/<repo>

tea actions variables list --repo <owner>/<repo>
tea actions variables set <name> <value> --repo <owner>/<repo>
tea actions variables delete <name> --repo <owner>/<repo>
```

Use `--repo` explicitly for Actions commands when automation might run outside the repository root.

## Notifications

```bash
tea notifications list
tea notifications list --mine --states unread,pinned --output json
tea notifications read <id>
tea notifications unread <id>
tea notifications pin <id>
tea notifications unpin <id>
```

Filters:

```bash
--types issue,pull,repository,commit
--states pinned,unread,read
--mine
```

## Authenticated API Requests

Use `tea api` when the CLI lacks a first-class subcommand or when you need an exact Gitea API endpoint.

```bash
tea api '/repos/{owner}/{repo}/issues?state=open'
tea api -X PATCH '/repos/{owner}/{repo}/issues/123' -F state='"closed"'
tea api -X POST '/repos/{owner}/{repo}/issues' -f title='Bug' -f body='Details'
tea api -X POST '/repos/{owner}/{repo}/issues' -d @payload.json
```

Endpoint behavior:

- Relative endpoints are prefixed with `/api/v1/`.
- `{owner}` and `{repo}` placeholders resolve from current repo context.
- Quote endpoints containing `?` or `&` to avoid shell expansion.
- `-f key=value` sends string fields.
- `-F key=value` sends typed values: numbers, booleans, null, JSON arrays/objects, or `@file` / `@-`.
- `-d @file` sends raw JSON and cannot be combined with `-f` / `-F`.
- A request body defaults the method to POST unless `-X` is set.

## Examples

### Create a PR for the current branch

```bash
tea pr create \
  --base main \
  --head "$(git branch --show-current)" \
  --title "feat(LKD-123): add booking reminder" \
  --description "$(printf '%s' "$PR_BODY")"
```

### Read high-signal PR context as JSON

```bash
tea pr 42 \
  --fields index,state,author,url,title,body,base,head,mergeable,ci,comments \
  --comments \
  --output json
```

### Resolve review comments after addressing feedback

```bash
tea pr review-comments 42 \
  --fields id,path,line,body,reviewer,resolver,url \
  --output json

tea pr resolve <comment-id>
```

### Use API for a narrow unsupported operation

```bash
tea api '/repos/{owner}/{repo}/pulls/42/requested_reviewers'
```

## Safety Notes

- Use `tea`, not `gh`, for Gitea repositories.
- Prefer `--output json` for automation and parsing.
- Pass `--repo <owner>/<repo>` or `--remote <name>` when repository context is not guaranteed.
- Read/list before mutate: inspect issues, PRs, review comments, releases, Actions, and secrets before editing them.
- Avoid destructive commands (`delete`, `merge`, `close`, `resolve`, `secrets delete`) unless the user asked for that exact action or the workflow explicitly requires it.
- Keep tokens out of command output, shell history, and committed files.
- If a subcommand is unclear, run `tea <command> --help` before acting.

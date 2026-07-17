---
name: acli-cli
description: "Use Atlassian's `acli` CLI to authenticate and work with Jira Cloud, Confluence Cloud, Atlassian admin users, and Rovo Dev from the terminal. Use this skill whenever the user mentions acli, Atlassian CLI, Jira work items/issues via CLI, JQL search, Jira comments/transitions/assignments, Jira boards/sprints/projects/filters, Confluence pages/spaces/blogs, Atlassian admin user operations, or Rovo Dev authentication. Prefer this over ad-hoc shell guesses for Atlassian terminal workflows."
---

# Atlassian CLI (`acli`)

Use this skill when the user wants to interact with Atlassian Cloud from the terminal. `acli` covers Jira Cloud work items, boards, sprints, projects, filters, Confluence Cloud pages/spaces/blogs, admin user operations, global authentication, and Rovo Dev authentication.

For rich Jira/Confluence lookups, MCP tools may be more convenient. Use `acli` when the user specifically asks for terminal commands, wants repeatable shell workflows, or needs CLI-shaped automation.

## Quick Reference

- `acli auth login` - Global OAuth login.
- `acli auth status` - Show global account status.
- `acli auth switch` - Switch active Atlassian account.
- `acli jira workitem search --jql "..." --json` - Search Jira work items with JQL.
- `acli jira workitem view KEY-123 --json` - View a Jira work item.
- `acli jira workitem create --project PROJ --type Task --summary "..."` - Create a work item.
- `acli jira workitem edit --key KEY-123 --summary "..."` - Edit a work item.
- `acli jira workitem transition --key KEY-123 --status Done` - Transition work item status.
- `acli jira workitem comment list --key KEY-123 --json` - List comments.
- `acli jira workitem comment create --key KEY-123 --body "..."` - Add a comment.
- `acli jira project list --json` - List visible Jira projects.
- `acli jira sprint list-workitems --board <id> --sprint <id> --json` - List sprint work items.
- `acli confluence page view --id <id> --json` - View a Confluence page.
- `acli confluence space list --json` - List Confluence spaces.
- `acli rovodev auth login` - Authenticate Rovo Dev.

## Output Formats

Many Jira and Confluence commands support:

```bash
--json
--csv
--fields key,summary,status
```

Use `--json` for scripts and agent workflows. Use `--fields` with Jira search/view commands to keep output small and stable.

`acli` does not use a single global `--output` flag like some CLIs. Check each subcommand's help for `--json`, `--csv`, `--fields`, `--paginate`, and `--limit`.

## Authentication

Global Atlassian OAuth:

```bash
acli auth login
acli auth status
acli auth switch
acli auth logout
```

Product-specific auth namespaces exist too:

```bash
acli jira auth login
acli jira auth status
acli jira auth switch
acli jira auth logout

acli confluence auth login
acli confluence auth status

acli admin auth login
```

Rovo Dev uses a separate scoped API token flow:

```bash
acli rovodev auth login
acli rovodev auth login --email "user@example.com" --token < token.txt
acli rovodev auth status
acli rovodev auth logout
```

Do not print tokens. For `rovodev auth login --token`, read the token from stdin rather than putting it directly in the command line.

## Jira Work Items

Jira Cloud's CLI uses `workitem` for issues/tasks/bugs/stories.

### Search

```bash
acli jira workitem search --jql "project = LKD AND status != Done" --json
acli jira workitem search --jql "project = LKD ORDER BY updated DESC" --fields "key,summary,assignee,status" --limit 50 --json
acli jira workitem search --jql "project = LKD" --paginate --json
acli jira workitem search --filter 10001 --json
acli jira workitem search --jql "project = LKD" --count
acli jira workitem search --jql "project = LKD" --web
```

Important flags:

- `--jql` / `-j` - Search by JQL.
- `--filter` - Search using a saved filter ID.
- `--fields` / `-f` - Comma-separated fields. Default: `issuetype,key,assignee,priority,status,summary`.
- `--limit` / `-l` - Maximum items to fetch.
- `--paginate` - Fetch all pages; ignores `--limit`.
- `--count` - Return count only.
- `--json` / `--csv` - Machine-readable output.

### View

```bash
acli jira workitem view LKD-123 --json
acli jira workitem view LKD-123 --fields summary,comment,status,assignee --json
acli jira workitem view LKD-123 --fields '*navigable,-comment' --json
acli jira workitem view LKD-123 --web
```

Field selectors:

- `*all` - All fields.
- `*navigable` - Navigable fields.
- `-fieldName` - Exclude a field.

### Create

```bash
acli jira workitem create \
  --project LKD \
  --type Bug \
  --summary "Crash when opening schedule" \
  --description "Plain text or Atlassian Document Format" \
  --assignee "@me" \
  --label mobile,bug \
  --json
```

Other creation modes:

```bash
acli jira workitem create --editor --project LKD --type Task
acli jira workitem create --from-file workitem.txt --project LKD --type Bug
acli jira workitem create --generate-json
acli jira workitem create --from-json workitem.json
acli jira workitem create --description-file description.txt --project LKD --type Story --summary "..."
```

### Edit, Assign, Transition

```bash
acli jira workitem edit --key LKD-123 --summary "New summary" --json
acli jira workitem edit --key "LKD-123,LKD-124" --description-file update.txt --yes --json
acli jira workitem edit --jql "project = LKD AND labels = cleanup" --labels cleanup,ready --yes
acli jira workitem edit --key LKD-123 --remove-labels old-label --yes

acli jira workitem assign --key LKD-123 --assignee "@me" --json
acli jira workitem assign --jql "project = LKD AND assignee is EMPTY" --assignee default --yes
acli jira workitem assign --key LKD-123 --remove-assignee --yes

acli jira workitem transition --key LKD-123 --status "In Progress" --json
acli jira workitem transition --jql "project = LKD AND status = 'To Do'" --status "In Progress" --yes
```

Bulk operations can target `--key`, `--jql`, `--filter`, or sometimes `--from-file`. Use `--yes` only after the targeted set is verified with `search`; bulk edits are easy to over-apply.

### Comments

```bash
acli jira workitem comment list --key LKD-123 --json
acli jira workitem comment list --key LKD-123 --limit 100 --order +created --json

acli jira workitem comment create --key LKD-123 --body "Status update" --json
acli jira workitem comment create --key LKD-123 --body-file comment.txt --json
acli jira workitem comment create --jql "project = LKD AND status = Blocked" --body-file comment.txt

acli jira workitem comment update --key LKD-123 --id 10001 --body "Updated comment"
acli jira workitem comment update --key LKD-123 --id 10001 --body-file comment.txt
acli jira workitem comment delete --key LKD-123 --id 10001
```

Use files for long comments. This avoids shell quoting bugs and preserves formatting.

### Attachments, Links, Watchers

```bash
acli jira workitem attachment list --key LKD-123
acli jira workitem attachment delete --key LKD-123 --id <attachment-id>

acli jira workitem link list --key LKD-123
acli jira workitem link type
acli jira workitem link create --help
acli jira workitem link delete --help

acli jira workitem list-watchers LKD-123
acli jira workitem watcher remove --help
```

Run subcommand help before creating/deleting links or removing watchers; options are relation-specific.

## Jira Boards, Sprints, Projects, Filters, Dashboards

```bash
acli jira project list --limit 50 --json
acli jira project list --paginate --json
acli jira project view LKD --json

acli jira board search --help
acli jira board view --help
acli jira board list-sprints --help
acli jira board list-projects --help

acli jira sprint view --help
acli jira sprint list-workitems --board <board-id> --sprint <sprint-id> --json
acli jira sprint list-workitems --board <board-id> --sprint <sprint-id> --fields "key,summary,status,assignee" --paginate --json

acli jira filter list --help
acli jira filter search --help
acli jira filter view --help
acli jira dashboard search --help
```

Prefer `--json` and explicit IDs for automation. For sprint work, use `board` and `sprint` IDs, not names, when possible.

## Confluence

### Pages

```bash
acli confluence page view --id <page-id> --json
acli confluence page view --id <page-id> --body-format storage --json
acli confluence page view --id <page-id> --body-format atlas_doc_format --include-version --json
acli confluence page view --id <page-id> --include-labels --include-direct-children --json
```

Useful page flags:

- `--body-format storage|atlas_doc_format|view`
- `--status current,draft,archived`
- `--version <number>`
- `--get-draft`
- `--include-labels`
- `--include-direct-children`
- `--include-version` / `--include-versions`
- `--include-properties`
- `--include-operations`

### Spaces

```bash
acli confluence space list --json
acli confluence space list --type global --status current --limit 50 --json
acli confluence space list --keys ENG,PROD --expand description,homepage --json
acli confluence space view <space-key> --json
acli confluence space create --help
acli confluence space update --help
acli confluence space archive <space-key>
acli confluence space restore <space-key>
```

### Blogs

```bash
acli confluence blog list --space-id <space-id> --json
acli confluence blog list --space-id <space-id> --title "Release Notes" --json
acli confluence blog list --id <blog-id> --json
acli confluence blog list --space-id <space-id> --body-format storage --limit 10 --json
acli confluence blog view --help
acli confluence blog create --help
```

## Admin Users

Admin commands require organization admin access and separate admin authentication.

```bash
acli admin auth login
acli admin user activate --help
acli admin user deactivate --help
acli admin user delete --help
acli admin user cancel-delete --help
```

Treat user activation/deactivation/deletion as destructive organizational operations. Inspect exact help and confirm target identity before acting.

## Rovo Dev

Rovo Dev commands may require a Rovo Dev scoped API token.

```bash
acli rovodev auth login
acli rovodev auth login --email "user@example.com" --token < token.txt
acli rovodev auth status
acli rovodev auth logout
```

If `acli rovodev run --help` fails before auth, authenticate first or report that Rovo Dev help is gated by Rovo Dev credentials.

## Examples

### Fetch a Jira ticket for implementation context

```bash
acli jira workitem view LKD-123 \
  --fields summary,status,assignee,description,comment \
  --json
```

### Search open bugs assigned to me

```bash
acli jira workitem search \
  --jql "project = LKD AND issuetype = Bug AND assignee = currentUser() AND statusCategory != Done ORDER BY priority DESC, updated DESC" \
  --fields "key,summary,status,priority,assignee" \
  --limit 50 \
  --json
```

### Add a formatted investigation comment

```bash
acli jira workitem comment create \
  --key LKD-123 \
  --body-file /tmp/lkd-123-investigation.md \
  --json
```

### Move verified tickets to Done

```bash
acli jira workitem search \
  --jql "key in (LKD-123, LKD-124)" \
  --fields "key,summary,status" \
  --json

acli jira workitem transition \
  --key "LKD-123,LKD-124" \
  --status "Done" \
  --yes \
  --json
```

### Read a Confluence page body as storage JSON

```bash
acli confluence page view \
  --id 123456789 \
  --body-format storage \
  --include-version \
  --json
```

## Safety Notes

- Use `--json` for automation and keep field lists narrow.
- Search/view before edit, transition, assign, delete, archive, or bulk-comment.
- For bulk operations, verify the target set with the exact JQL/filter first, then rerun with the mutating command and `--yes` only if needed.
- Put long descriptions/comments in files via `--description-file`, `--body-file`, or JSON files. This avoids quoting problems and accidental truncation.
- Do not expose OAuth tokens or Rovo Dev API tokens in command arguments, logs, committed files, or final answers.
- If a command is unclear or destructive, run `acli <command> --help` before acting.

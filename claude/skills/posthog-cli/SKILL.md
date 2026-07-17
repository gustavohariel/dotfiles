---
name: posthog-cli
description: "Use the globally installed posthog-cli to authenticate with PostHog, upload sourcemaps/Hermes maps/dSYMs/ProGuard mappings, inspect symbol sets, run experimental SQL queries, sync endpoint YAML files, and generate typed event schemas. Use this skill whenever the user mentions posthog-cli, PostHog CLI, sourcemaps, Hermes source maps, dSYM uploads, ProGuard mappings, symbol sets, PostHog endpoint YAML, PostHog SQL from the terminal, or schema generation via the CLI. Prefer this over ad-hoc commands for PostHog release artifact and CI workflows."
---

# PostHog CLI (`posthog-cli`)

Use this skill when the user wants to interact with PostHog through the globally installed CLI rather than the MCP tools or web UI. It is especially useful for release/CI work: sourcemaps, Hermes maps, dSYMs, ProGuard mappings, symbol-set inspection, endpoint YAML sync, and typed schema generation.

## Quick Reference

- `posthog-cli login` - Interactive auth; stores credentials locally.
- `posthog-cli sourcemap process -d <dir>` - Inject IDs and upload web/source-map bundles.
- `posthog-cli hermes inject -d <dir>` - Inject chunk/release metadata into Hermes bundle maps.
- `posthog-cli hermes upload -d <dir>` - Upload bundled Hermes source maps.
- `posthog-cli dsym upload -d <dir>` - Upload iOS/macOS dSYM files.
- `posthog-cli proguard upload --path <mapping.txt> --map-id <id>` - Upload Android ProGuard mapping.
- `posthog-cli symbol-sets download --id <id> -o <dir>` - Download and extract an uploaded symbol set.
- `posthog-cli exp query run '<sql>'` - Run a PostHog SQL query and emit JSON lines.
- `posthog-cli exp endpoints pull --all -o <dir>` - Pull endpoint YAML files.
- `posthog-cli exp schema pull -o <path>` - Generate typed event definitions.

## Global Options

Place global options before the subcommand:

```bash
posthog-cli --host https://app.posthog.com <command>
posthog-cli --dotenv-file .env.posthog <command>
posthog-cli --dry-run hermes upload -d dist/hermes
```

- `--host <HOST>` - Target PostHog host, useful for EU/self-hosted instances.
- `--dotenv-file <PATH>` - Load `POSTHOG_CLI_API_KEY` and `POSTHOG_CLI_PROJECT_ID` from a dotenv file. Prefer this spelling over `--env-file`; the npm wrapper can intercept Node's own `--env-file` flag.
- `--dry-run[=true|false]` - Validate artifact processing without contacting PostHog or requiring credentials. Good for CI gates, not release uploads.
- `--rate-limit <N>` - API requests per minute; also supports `POSTHOG_CLIENT_RATE_LIMIT`.
- `--skip-ssl-verification` - Only for self-signed/self-hosted instances.
- `--no-fail` - Converts errors to success. Avoid in release workflows unless the user explicitly wants non-blocking telemetry upload.

## Authentication

```bash
posthog-cli login
```

The CLI also reads credentials from environment variables:

```bash
POSTHOG_CLI_API_KEY=<personal-api-key>
POSTHOG_CLI_PROJECT_ID=<project-id>
```

For CI, prefer a dotenv file or environment variables injected by the CI secret store. Do not print tokens or commit dotenv files containing credentials.

## Release Metadata

Artifact upload commands accept common release flags:

```bash
--release-name <NAME>
--release-version <VERSION>
--build <BUILD>
--skip-release-on-fail
```

Set `--release-name` and `--release-version` explicitly in CD workflows. The CLI can try to infer them from git, but explicit values keep symbolication stable across build machines and detached checkouts.

Conflict handling:

- `--force` overwrites an existing symbol set if content changed.
- `--skip-on-conflict` leaves remote symbol sets unchanged and skips conflicting uploads.
- `--skip-release-on-fail` retries without release association on `release_id_mismatch`.

Choose one deliberately. Do not add `--force` just to make CI green unless overwriting is the desired release behavior.

## Commands

### Sourcemaps

For ordinary bundled chunks with sourcemaps:

```bash
posthog-cli sourcemap inject -d <directory>
posthog-cli sourcemap upload -d <directory>
posthog-cli sourcemap process -d <directory>
```

Useful options:

```bash
--include <glob>
--exclude <glob>
--stdin
--public-path-prefix <prefix>
--delete-after
--batch-size <N>
--release-name <NAME>
--release-version <VERSION>
--build <BUILD>
--force
--skip-on-conflict
```

`process` runs `inject` then `upload`. Use separate `inject` and `upload` when the build pipeline needs to inspect or package the injected files before upload.

### Hermes Source Maps

For React Native/Hermes bundles:

```bash
posthog-cli hermes inject -d <directory>
posthog-cli hermes upload -d <directory>
posthog-cli hermes clone \
  --minified-map-path <index.bundle.map> \
  --composed-map-path <index.bundle.packager.map>
```

Use `clone` when the build creates a minified map and a composed map and the composed map needs the same `chunk_id` / `release_id` metadata before upload.

### dSYM Files

For iOS/macOS symbolication:

```bash
posthog-cli dsym upload -d <dsym-directory>
posthog-cli dsym upload \
  -d "$DWARF_DSYM_FOLDER_PATH" \
  --main-dsym "$DWARF_DSYM_FILE_NAME" \
  --release-name <NAME> \
  --release-version <VERSION> \
  --build <BUILD>
```

Options:

- `--main-dsym <NAME>` - Tells the CLI which dSYM contains version info when multiple dSYMs are present.
- `--include-source` - Uploads source context from DWARF debug info. This implies `--force` unless `--skip-on-conflict` is set.

### ProGuard Mappings

For Android stack-trace deobfuscation:

```bash
posthog-cli proguard upload \
  --path <mapping.txt> \
  --map-id <map-id> \
  --release-name <NAME> \
  --release-version <VERSION> \
  --build <BUILD>
```

`--map-id` must match the identifier provided to the PostHog SDK at runtime for that build. If the runtime ID and uploaded map ID differ, PostHog cannot symbolicate/deobfuscate the stack trace.

### Symbol Sets

```bash
posthog-cli symbol-sets download --id <symbol-set-id> -o <output-dir>
posthog-cli symbol-sets download --ref <symbol-set-ref> -o <output-dir>
posthog-cli symbol-sets extract <symbol-set-file> -o <output-dir>
```

Use these commands to inspect what was uploaded, debug symbolication, or compare local artifacts with remote symbol sets.

### Experimental SQL Queries

```bash
posthog-cli exp query check 'SELECT 1'
posthog-cli exp query check --raw '<sql>'
posthog-cli exp query run '<sql>'
posthog-cli exp query run --debug '<sql>'
posthog-cli exp query editor
```

`run` prints JSON lines. Use `check` before expensive or destructive investigation queries to validate syntax and types without running the query.

### Experimental Endpoint YAML

```bash
posthog-cli exp endpoints list
posthog-cli exp endpoints get <name>
posthog-cli exp endpoints open <name>
posthog-cli exp endpoints run <name>
posthog-cli exp endpoints run --file ./endpoint.yaml --var key=value --format json
posthog-cli exp endpoints pull --all -o ./posthog-endpoints
posthog-cli exp endpoints pull <name> -o ./endpoint.yaml
posthog-cli exp endpoints diff ./posthog-endpoints
posthog-cli exp endpoints push ./posthog-endpoints --dry-run
posthog-cli exp endpoints push ./posthog-endpoints --yes
```

Workflow for changing endpoints:

1. Pull remote YAML first.
2. Edit locally.
3. Run `diff` to review remote/local changes.
4. Run `push --dry-run` before `push --yes`.

### Experimental Schema Generation

```bash
posthog-cli exp schema status
posthog-cli exp schema pull -o <output-path>
```

`schema pull` downloads event definitions and generates typed SDK definitions. The output path is stored in `posthog.json` for future runs.

### Experimental Tasks

```bash
posthog-cli exp task list --limit 20
posthog-cli exp task progress <task-id>
posthog-cli exp task update-stage <task-id>
```

If `<task-id>` is omitted for `progress` or `update-stage`, the CLI prompts interactively.

## Examples

### Validate a Hermes upload in CI without credentials

```bash
posthog-cli --dry-run hermes upload \
  -d dist/hermes \
  --release-name leko-mobile \
  --release-version "$GIT_SHA" \
  --build "$BUILD_NUMBER"
```

### Upload iOS dSYMs from an Xcode build phase

```bash
posthog-cli --dotenv-file .env.posthog dsym upload \
  -d "$DWARF_DSYM_FOLDER_PATH" \
  --main-dsym "$DWARF_DSYM_FILE_NAME" \
  --release-name leko-mobile \
  --release-version "$MARKETING_VERSION" \
  --build "$CURRENT_PROJECT_VERSION" \
  --skip-on-conflict
```

### Pull and review endpoint YAML

```bash
posthog-cli exp endpoints pull --all -o ./posthog-endpoints
posthog-cli exp endpoints diff ./posthog-endpoints
```

### Check a SQL query before running it

```bash
posthog-cli exp query check 'SELECT event, count() FROM events GROUP BY event LIMIT 10'
posthog-cli exp query run 'SELECT event, count() FROM events GROUP BY event LIMIT 10'
```

## Safety Notes

- Treat `exp` commands as unstable. Prefer `--dry-run`, `diff`, `check`, and explicit output paths before changing remote state.
- Avoid `--no-fail` in CI release steps unless uploads are intentionally best-effort.
- Never echo or commit `POSTHOG_CLI_API_KEY`.
- Use MCP PostHog tools for rich product analytics exploration when available; use `posthog-cli` for repeatable terminal workflows, artifacts, endpoints, and schemas.
- If command behavior is uncertain, run `posthog-cli <command> --help` before acting.

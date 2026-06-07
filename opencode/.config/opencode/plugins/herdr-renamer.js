import { execFileSync } from "child_process"

function herdr(args) {
  return execFileSync("herdr", args, {
    encoding: "utf8",
    timeout: 3000,
    stdio: ["pipe", "pipe", "ignore"],
  })
}

function opencode(args) {
  return execFileSync("opencode", args, {
    encoding: "utf8",
    timeout: 15000,
    stdio: ["pipe", "pipe", "ignore"],
  })
}

function renameWorkspace(id, label) {
  try { herdr(["workspace", "rename", id, label.slice(0, 60)]) } catch {}
}

function renamePane(id, label) {
  try { herdr(["pane", "rename", id, label.slice(0, 60)]) } catch {}
}

function renameTab(id, label) {
  try { herdr(["tab", "rename", id, label.slice(0, 60)]) } catch {}
}

function getSessionTitle() {
  const out = opencode(["session", "list"])
  const lines = out.split("\n").filter((l) => l.startsWith("ses_"))
  if (!lines.length) return null

  const line = lines[0]
  const sessionId = line.match(/^(ses_[a-zA-Z0-9]+)\s{2,}/)?.[1]
  if (!sessionId) return null

  const rest = line.slice(sessionId.length).trimStart()
  const title = rest.replace(/\s{2,}.*$/, "").trim()
  return title || null
}

function extractNameHeuristic(text) {
  const cleaned = text
    .replace(/^(can you|please|i need|i want|help me|let's|lets)\s+/i, "")
    .replace(/^new session[^a-z].*/i, "task")
    .replace(/^opencode\s+/i, "")
    .replace(/https?:\/\/\S+/g, "")
    .replace(/-+/g, " ")
    .replace(/[^a-z0-9\s]/gi, "")
    .trim()
    .split(/\s+/)
    .filter((w) => w.length > 2 && !/^(opencode|with|from|this|that|the|and|for|discussion)$/i.test(w))
    .slice(0, 3)
    .join("-")
    .toLowerCase()

  return cleaned || "task"
}

export default async () => {
  let done = false

  return {
    event: async (input) => {
      if (done) return
      const type = input?.event?.type
      if (type !== "session.idle") return

      try {
        const raw = JSON.parse(herdr(["workspace", "list"]))
        const workspaces = raw.result?.workspaces ?? []
        const ws = workspaces.find((w) => w.worktree?.is_linked_worktree && w.focused)
        if (!ws?.worktree) return

        const sessionTitle = getSessionTitle()
        if (!sessionTitle) return

        const wsName = extractNameHeuristic(sessionTitle)

        renameTab(ws.active_tab_id, "opencode")
        renameWorkspace(ws.workspace_id, wsName)
        renamePane(ws.workspace_id + "-1", wsName)

        done = true
      } catch {}
    },
  }
}

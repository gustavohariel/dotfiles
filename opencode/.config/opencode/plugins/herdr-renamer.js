import { execFileSync } from "child_process"

function herdr(args) {
  return execFileSync("herdr", args, {
    encoding: "utf8",
    timeout: 3000,
    stdio: ["pipe", "pipe", "ignore"],
  })
}

function renameWorkspace(id, label) {
  try { herdr(["workspace", "rename", id, label]) } catch {}
}

function renamePane(id, label) {
  try { herdr(["pane", "rename", id, label]) } catch {}
}

function renameTab(id, label) {
  try { herdr(["tab", "rename", id, label]) } catch {}
}

function extractName(text) {
  const cleaned = text
    .replace(/^(can you|please|i need|i want|help me|let's|lets)\s+/i, "")
    .replace(/https?:\/\/\S+/g, "")
    .replace(/[^a-z0-9\s-]/gi, "")
    .trim()
    .split(/\s+/)
    .filter((w) => w.length > 2)
    .slice(0, 4)
    .join("-")
    .toLowerCase()

  return cleaned.length > 60 ? cleaned.slice(0, 60) : cleaned
}

export default async () => {
  let done = false
  let pendingName = null

  return {
    chat: {
      params: async (input) => {
        if (done) return
        const messages = input?.messages ?? []
        const last = messages[messages.length - 1]
        if (last?.role !== "user" || !last?.content) return

        const text = typeof last.content === "string" ? last.content : ""
        pendingName = extractName(text)
      },
    },

    event: async (input) => {
      if (done || !pendingName) return
      const type = input?.event?.type
      if (type !== "session.idle" && type !== "session.status") return
      done = true

      try {
        const raw = JSON.parse(herdr(["workspace", "list"]))
        const workspaces = raw.result?.workspaces ?? []
        const ws = workspaces.find((w) => w.worktree?.is_linked_worktree && w.focused)
        if (!ws?.worktree) return

        renameWorkspace(ws.workspace_id, pendingName)
        renamePane(ws.workspace_id + "-1", pendingName)
        renameTab(ws.active_tab_id, pendingName)
      } catch {}
    },
  }
}

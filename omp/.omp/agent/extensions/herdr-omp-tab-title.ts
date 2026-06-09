// local herdr hook: mirror the OMP session title into the current Herdr tab label.
// Keep this beside herdr-managed integration files so reinstalls do not overwrite it.
// @ts-nocheck

import { createConnection } from "node:net";

const HERDR_ENV = process.env.HERDR_ENV;
const socketPath = process.env.HERDR_SOCKET_PATH;
const paneId = process.env.HERDR_PANE_ID;
const source = "herdr:omp-tab-title";

const requestTimeoutMs = parseDurationEnv("HERDR_OMP_TAB_TITLE_TIMEOUT_MS", 500);
const refreshMs = parseDurationEnv("HERDR_OMP_TAB_TITLE_REFRESH_MS", 1000);
const maxTitleLength = parseDurationEnv("HERDR_OMP_TAB_TITLE_MAX_LENGTH", 80);

function enabled() {
  return HERDR_ENV === "1" && !!socketPath && !!paneId;
}

function parseDurationEnv(name, fallback) {
  const raw = process.env[name];
  if (!raw) {
    return fallback;
  }
  const parsed = Number.parseInt(raw, 10);
  if (!Number.isFinite(parsed) || parsed < 0) {
    return fallback;
  }
  return parsed;
}

function requestId() {
  return `${source}:${Date.now()}:${Math.random().toString(36).slice(2)}`;
}

function sendRequest(request) {
  if (!enabled()) {
    return Promise.resolve(undefined);
  }

  const { promise, resolve } = Promise.withResolvers();
  let done = false;
  let buffer = "";
  let timeout;
  const socket = createConnection(socketPath);

  const finish = (response) => {
    if (done) return;
    done = true;
    clearTimeout(timeout);
    socket.destroy();
    resolve(response);
  };

  socket.on("error", () => finish(undefined));
  socket.on("connect", () => socket.write(`${JSON.stringify(request)}\n`));
  socket.on("data", (chunk) => {
    buffer += chunk.toString("utf8");
    const newline = buffer.indexOf("\n");
    if (newline === -1) {
      return;
    }

    try {
      finish(JSON.parse(buffer.slice(0, newline)));
    } catch {
      finish(undefined);
    }
  });
  socket.on("end", () => finish(undefined));

  timeout = setTimeout(() => finish(undefined), requestTimeoutMs);
  timeout.unref?.();

  return promise;
}

function normalizeTitle(value) {
  if (typeof value !== "string") {
    return undefined;
  }

  const title = value
    .replace(/[\x00-\x1F\x7F]/g, " ")
    .replace(/\s+/g, " ")
    .trim();

  if (!title) {
    return undefined;
  }
  if (maxTitleLength > 0 && title.length > maxTitleLength) {
    return title.slice(0, Math.max(1, maxTitleLength - 1)) + "…";
  }
  return title;
}

export default function (pi) {
  if (!enabled()) {
    return;
  }

  let tabId;
  let originalTabLabel;
  let loadedOriginalTabLabel = false;
  let lastPublishedLabel;
  let syncInFlight = false;
  let syncQueued = false;
  let interval;
  let started = false;

  async function resolveCurrentTab() {
    if (tabId) {
      return tabId;
    }

    const paneResponse = await sendRequest({
      id: requestId(),
      method: "pane.get",
      params: {
        pane_id: paneId,
      },
    });

    const resolvedTabId = paneResponse?.result?.pane?.tab_id;
    if (typeof resolvedTabId !== "string" || !resolvedTabId) {
      return undefined;
    }

    tabId = resolvedTabId;

    if (!loadedOriginalTabLabel) {
      loadedOriginalTabLabel = true;
      const tabResponse = await sendRequest({
        id: requestId(),
        method: "tab.get",
        params: {
          tab_id: tabId,
        },
      });
      const label = tabResponse?.result?.tab?.label;
      if (typeof label === "string" && label) {
        originalTabLabel = label;
        lastPublishedLabel = label;
      }
    }

    return tabId;
  }

  function getSessionTitle() {
    try {
      return normalizeTitle(pi.getSessionName?.());
    } catch {
      return undefined;
    }
  }

  async function syncTabTitle() {
    const currentTabId = await resolveCurrentTab();
    if (!currentTabId) {
      return;
    }

    const nextLabel = getSessionTitle() ?? originalTabLabel;
    if (!nextLabel || nextLabel === lastPublishedLabel) {
      return;
    }

    const response = await sendRequest({
      id: requestId(),
      method: "tab.rename",
      params: {
        tab_id: currentTabId,
        label: nextLabel,
      },
    });

    if (response?.result) {
      lastPublishedLabel = nextLabel;
    }
  }

  async function drainSyncQueue() {
    if (syncInFlight) {
      return;
    }

    syncInFlight = true;
    try {
      do {
        syncQueued = false;
        await syncTabTitle();
      } while (syncQueued);
    } finally {
      syncInFlight = false;
    }
  }

  function queueSync() {
    if (!started) {
      return;
    }

    syncQueued = true;
    if (!syncInFlight) {
      void drainSyncQueue();
    }
  }

  function start() {
    if (started) {
      queueSync();
      return;
    }

    started = true;
    if (refreshMs > 0) {
      interval = setInterval(queueSync, refreshMs);
      interval.unref?.();
    }
    queueSync();
  }

  pi.on("session_start", start);
  pi.on("turn_end", queueSync);
  pi.on("agent_end", queueSync);
  pi.on("message_end", queueSync);

  pi.on("session_shutdown", () => {
    started = false;
    if (interval) {
      clearInterval(interval);
      interval = undefined;
    }
  });
}

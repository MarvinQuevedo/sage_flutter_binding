// dApp approval queue.
//
// When a dApp triggers a method that needs explicit user consent
// (connect, signCoinSpends, signMessage, sendTransaction, etc.) the
// background service worker stashes the request in a pending map and
// opens a chrome.windows popup pointing at `approve.html?id=<requestId>`.
// The approval page polls back via chrome.runtime.sendMessage with
// `{kind: "approval-decide", id, approved}` and we resolve the pending
// Promise here.

import type { ChiaMethod } from "@ozone/goby-provider/types";

export interface PendingRequest {
  id: string;
  origin: string;
  method: ChiaMethod;
  params: unknown;
  createdAt: number;
}

interface PendingEntry {
  request: PendingRequest;
  resolve: (approved: boolean) => void;
  windowId?: number;
}

const PENDING = new Map<string, PendingEntry>();

function newId(): string {
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;
}

/** Request user approval. Resolves to true (approve) or false (reject). */
export function requestApproval(
  origin: string,
  method: ChiaMethod,
  params: unknown,
): Promise<boolean> {
  const request: PendingRequest = {
    id: newId(),
    origin,
    method,
    params,
    createdAt: Date.now(),
  };

  return new Promise<boolean>((resolve) => {
    const entry: PendingEntry = { request, resolve };
    PENDING.set(request.id, entry);

    void chrome.windows
      .create({
        url: chrome.runtime.getURL(`approve.html?id=${request.id}`),
        type: "popup",
        width: 400,
        height: 600,
        focused: true,
      })
      .then((win) => {
        if (win?.id != null) entry.windowId = win.id;
      })
      .catch(() => {
        // If we can't open the window, reject by default.
        PENDING.delete(request.id);
        resolve(false);
      });
  });
}

export function getPending(id: string): PendingRequest | null {
  return PENDING.get(id)?.request ?? null;
}

export function decidePending(id: string, approved: boolean): boolean {
  const entry = PENDING.get(id);
  if (!entry) return false;
  PENDING.delete(id);
  entry.resolve(approved);
  if (entry.windowId != null) {
    void chrome.windows.remove(entry.windowId).catch(() => {});
  }
  return true;
}

/** Called when an approval window closes without a decision — auto-reject. */
export function cancelPending(id: string): void {
  const entry = PENDING.get(id);
  if (!entry) return;
  PENDING.delete(id);
  entry.resolve(false);
}

/** Auto-reject every pending if the user explicitly locks the wallet. */
export function cancelAll(): void {
  for (const id of [...PENDING.keys()]) cancelPending(id);
}

export type ApprovalMessage =
  | { from: "approval"; kind: "fetch"; id: string }
  | { from: "approval"; kind: "decide"; id: string; approved: boolean };

export type ApprovalResponse =
  | { ok: true; request?: PendingRequest }
  | { ok: false; error: string };

export function isApprovalMessage(msg: unknown): msg is ApprovalMessage {
  return (
    typeof msg === "object" &&
    msg !== null &&
    (msg as { from?: unknown }).from === "approval"
  );
}

export async function handleApprovalMessage(msg: ApprovalMessage): Promise<ApprovalResponse> {
  switch (msg.kind) {
    case "fetch": {
      const req = getPending(msg.id);
      if (!req) return { ok: false, error: "no pending request with that id" };
      return { ok: true, request: req };
    }
    case "decide": {
      const found = decidePending(msg.id, msg.approved);
      if (!found) return { ok: false, error: "no pending request with that id" };
      return { ok: true };
    }
  }
}

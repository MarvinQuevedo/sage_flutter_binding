// Inpage script — runs in MAIN world of every page. Defines window.chia.
// Talks to the content script via window.postMessage.

import {
  type ChainId,
  type ChiaEvent,
  type ChiaMethod,
  type ChiaMethodMap,
  type ChiaWallet,
  CONTENT_TARGET,
  PAGE_TARGET,
  type PageEventMessage,
  type PageResponseMessage,
  type RequestArguments,
} from "./types.js";

const NAME = "Ozone";
const VERSION = "0.0.1";
const API_VERSION = "1.0.0";

type Pending = {
  resolve: (value: unknown) => void;
  reject: (reason: unknown) => void;
};

const pending = new Map<number, Pending>();
const listeners = new Map<ChiaEvent, Set<(...args: any[]) => void>>();
let nextId = 1;

let _chainId: ChainId | undefined;
let _selectedAddress: string | undefined;
let _connected = false;

function postRequest<M extends ChiaMethod>(
  method: M,
  params: ChiaMethodMap[M]["params"],
): Promise<ChiaMethodMap[M]["result"]> {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    pending.set(id, { resolve: resolve as (v: unknown) => void, reject });
    window.postMessage(
      {
        target: CONTENT_TARGET,
        id,
        origin: window.location.origin,
        method,
        params,
      },
      window.location.origin,
    );
  });
}

window.addEventListener("message", (ev: MessageEvent) => {
  if (ev.source !== window) return;
  const data = ev.data;
  if (!data || data.target !== PAGE_TARGET) return;

  // Response to a request
  if (typeof (data as PageResponseMessage).id === "number") {
    const msg = data as PageResponseMessage;
    const p = pending.get(msg.id);
    if (!p) return;
    pending.delete(msg.id);
    if (msg.error) {
      const err = new Error(msg.error.message) as Error & {
        code?: number;
        data?: unknown;
      };
      err.code = msg.error.code;
      err.data = msg.error.data;
      p.reject(err);
    } else {
      p.resolve(msg.result);
    }
    return;
  }

  // Server-pushed event
  if ((data as PageEventMessage).event) {
    const msg = data as PageEventMessage;
    if (msg.event === "chainChanged") {
      _chainId = (msg.payload as { chainId: ChainId }).chainId;
    }
    if (msg.event === "accountChanged") {
      _selectedAddress = undefined; // dApp must re-fetch
    }
    const set = listeners.get(msg.event);
    if (set) {
      for (const fn of set) {
        try {
          fn(msg.payload);
        } catch (e) {
          console.error("[Ozone] event listener threw", e);
        }
      }
    }
  }
});

const provider: ChiaWallet = {
  name: NAME,
  version: VERSION,
  apiVersion: API_VERSION,
  isGoby: true,
  isOzone: true,

  get chainId() {
    return _chainId;
  },
  get selectedAddress() {
    return _selectedAddress;
  },
  isConnected() {
    return _connected;
  },

  async request<M extends ChiaMethod>(args: RequestArguments<M>) {
    const result = await postRequest(args.method, args.params as ChiaMethodMap[M]["params"]);
    if (args.method === "connect") {
      _connected = Boolean(result);
    }
    return result;
  },

  on(event, listener) {
    let set = listeners.get(event);
    if (!set) {
      set = new Set();
      listeners.set(event, set);
    }
    set.add(listener);
  },

  off(event, listener) {
    listeners.get(event)?.delete(listener);
  },

  removeListener(event, listener) {
    listeners.get(event)?.delete(listener);
  },
};

// Inject. Don't clobber an existing wallet — let the user / dApp pick.
if (!window.chia) {
  Object.defineProperty(window, "chia", { value: provider, writable: false, configurable: false });
}
Object.defineProperty(window, "ozone", { value: provider, writable: false, configurable: false });

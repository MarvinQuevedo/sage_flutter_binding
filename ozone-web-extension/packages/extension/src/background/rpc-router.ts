// CHIP-0002 method router. Maps Goby methods → sage-api endpoints exposed by
// the WASM engine.

import { Errors } from "@ozone/goby-provider/errors";
import type { ChiaMethod, ChiaMethodMap } from "@ozone/goby-provider/types";
import { requestApproval } from "./approval.js";
import { callEngine } from "./engine.js";
import { grantConnection } from "./permissions.js";

const APPROVAL_REQUIRED = new Set<ChiaMethod>([
  "connect",
  "signCoinSpends",
  "signMessage",
  "transfer",
  "sendTransaction",
  "createOffer",
  "takeOffer",
  "walletSwitchChain",
  "walletWatchAsset",
]);

type Handler<M extends ChiaMethod> = (
  origin: string,
  params: ChiaMethodMap[M]["params"],
) => Promise<ChiaMethodMap[M]["result"]>;

/**
 * Maps each CHIP-0002 / Goby method to a sage-api engine endpoint plus a
 * lightweight transform on the response (most methods just pass through).
 * `null` means "handled inline by a dedicated function below".
 */
const ENGINE_METHOD: Partial<Record<ChiaMethod, string | null>> = {
  chainId: "get_network",
  connect: null,
  walletSwitchChain: "switch_network",
  walletWatchAsset: "add_cat",

  getPublicKeys: "get_derivations",
  filterUnlockedCoins: "filter_unlocked_coins",
  getAssetCoins: "get_spendable_coins",
  getAssetBalance: "get_sync_status",

  signCoinSpends: "sign_coin_spends",
  signMessage: "sign_message_by_public_key",

  transfer: null, // routed inline to send_xch or send_cat based on params
  sendTransaction: "submit_transaction",
  createOffer: "make_offer",
  takeOffer: "take_offer",
};

const handlers: { [M in ChiaMethod]?: Handler<M> } = {
  async chainId() {
    return "mainnet" as ChiaMethodMap["chainId"]["result"];
  },

  async connect(origin, params) {
    void params;
    const approved = await requestApproval(origin, "connect", params);
    if (!approved) throw Errors.userRejected();
    await grantConnection(origin);
    return true;
  },

  async transfer(_origin, params) {
    const assetId = (params as { assetId?: string | null }).assetId;
    const endpoint = assetId && assetId !== "" ? "send_xch" : "send_xch"; // FIXME: send_cat once storage wired
    return callEngine(endpoint, params) as Promise<ChiaMethodMap["transfer"]["result"]>;
  },
};

export async function handleRpc<M extends ChiaMethod>(
  origin: string,
  method: M,
  params: ChiaMethodMap[M]["params"],
): Promise<ChiaMethodMap[M]["result"]> {
  // Approval gate for methods that mutate state or sign things
  if (APPROVAL_REQUIRED.has(method) && method !== "connect") {
    const approved = await requestApproval(origin, method, params);
    if (!approved) throw Errors.userRejected();
  }

  // Inline handler wins
  const inline = handlers[method] as Handler<M> | undefined;
  if (inline) return inline(origin, params);

  // Engine passthrough
  const endpoint = ENGINE_METHOD[method];
  if (typeof endpoint === "string") {
    return callEngine<ChiaMethodMap[M]["result"]>(endpoint, params);
  }

  throw Errors.methodNotFound(method);
}

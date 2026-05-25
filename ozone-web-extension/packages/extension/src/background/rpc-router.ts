// CHIP-0002 method router. Maps Goby methods → sage-api endpoints.
// Stubbed for now (WASM module not yet built). Each handler will route to
// `wallet.request(endpoint, params)` once the WASM bindings exist.

import { Errors } from "@ozone/goby-provider/errors";
import type { ChiaMethod, ChiaMethodMap } from "@ozone/goby-provider/types";
import { grantConnection } from "./permissions.js";

type Handler<M extends ChiaMethod> = (
  origin: string,
  params: ChiaMethodMap[M]["params"],
) => Promise<ChiaMethodMap[M]["result"]>;

const handlers: { [M in ChiaMethod]?: Handler<M> } = {
  async chainId() {
    // TODO: read from settings (mainnet / testnet11)
    return "mainnet";
  },

  async connect(origin, params) {
    // TODO: open approval popup; if user confirms:
    void params;
    await grantConnection(origin);
    return true;
  },

  async getPublicKeys() {
    throw Errors.methodNotFound("getPublicKeys (WASM not wired)");
  },

  async filterUnlockedCoins() {
    throw Errors.methodNotFound("filterUnlockedCoins (WASM not wired)");
  },

  async getAssetCoins() {
    throw Errors.methodNotFound("getAssetCoins (WASM not wired)");
  },

  async getAssetBalance() {
    throw Errors.methodNotFound("getAssetBalance (WASM not wired)");
  },

  async signCoinSpends() {
    throw Errors.methodNotFound("signCoinSpends (WASM not wired)");
  },

  async signMessage() {
    throw Errors.methodNotFound("signMessage (WASM not wired)");
  },

  async transfer() {
    throw Errors.methodNotFound("transfer (WASM not wired)");
  },

  async sendTransaction() {
    throw Errors.methodNotFound("sendTransaction (WASM not wired)");
  },

  async createOffer() {
    throw Errors.methodNotFound("createOffer (WASM not wired)");
  },

  async takeOffer() {
    throw Errors.methodNotFound("takeOffer (WASM not wired)");
  },

  async walletSwitchChain() {
    throw Errors.methodNotFound("walletSwitchChain (WASM not wired)");
  },

  async walletWatchAsset() {
    throw Errors.methodNotFound("walletWatchAsset (WASM not wired)");
  },
};

export async function handleRpc<M extends ChiaMethod>(
  origin: string,
  method: M,
  params: ChiaMethodMap[M]["params"],
): Promise<ChiaMethodMap[M]["result"]> {
  const handler = handlers[method] as Handler<M> | undefined;
  if (!handler) throw Errors.methodNotFound(method);
  return handler(origin, params);
}

// CHIP-0002 + Goby extensions — wire types
// Source: docs.goby.app + chips/chip-0002.md + vendor/sage walletconnect commands

export type ChainId = "mainnet" | "testnet11" | (string & {});

export type Hex = `0x${string}` | string;
export type Amount = number | string; // accept both; carry as string internally for >2^53 mojos

export interface Coin {
  parent_coin_info: Hex;
  puzzle_hash: Hex;
  amount: number;
}

export interface CoinSpend {
  coin: Coin;
  puzzle_reveal: Hex;
  solution: Hex;
}

export interface SpendBundle {
  coin_spends: CoinSpend[];
  aggregated_signature: Hex;
}

export interface SpendableCoin {
  coin: Coin;
  coinName: Hex;
  puzzle: Hex;
  confirmedBlockIndex: number;
  locked: boolean;
  lineageProof?: {
    parentName?: Hex;
    innerPuzzleHash?: Hex;
    amount?: number;
  };
}

export interface AssetBalance {
  confirmed: string; // mojos as string
  spendable: string;
  spendableCoinCount: number;
}

export type AssetType = "cat" | "did" | "nft" | null;

export enum MempoolInclusionStatus {
  SUCCESS = 1,
  PENDING = 2,
  FAILED = 3,
}

export interface TransactionResp {
  status: MempoolInclusionStatus;
  error?: string | null;
}

// ─── Method param/return maps ────────────────────────────────────────────────

export interface ChiaMethodMap {
  // CHIP-0002 — Connection & meta
  chainId: { params: void; result: ChainId };
  connect: { params: { eager?: boolean } | undefined; result: boolean };
  walletSwitchChain: { params: { chainId: ChainId }; result: null };
  walletWatchAsset: {
    params: {
      type: string;
      options: { assetId: Hex; symbol: string; logo?: string };
    };
    result: boolean;
  };

  // CHIP-0002 — Read
  getPublicKeys: {
    params: { limit?: number; offset?: number; hardened?: boolean } | undefined;
    result: Hex[];
  };
  filterUnlockedCoins: {
    params: { coinNames: Hex[] };
    result: Hex[];
  };
  getAssetCoins: {
    params: {
      type: AssetType;
      assetId: Hex | null;
      includedLocked?: boolean;
      offset?: number;
      limit?: number;
    };
    result: SpendableCoin[];
  };
  getAssetBalance: {
    params: { type: AssetType; assetId: Hex | null };
    result: AssetBalance;
  };

  // CHIP-0002 — Signing
  signCoinSpends: {
    params: { coinSpends: CoinSpend[]; partialSign?: boolean };
    result: Hex; // BLS aggregated signature
  };
  signMessage: {
    params: { message: Hex; publicKey: Hex };
    result: Hex;
  };

  // Goby extensions
  transfer: {
    params: {
      to: string;
      amount: Amount;
      assetId: Hex | "" | null;
      memos?: Hex[];
      fee?: Amount;
    };
    result: { id: Hex };
  };
  sendTransaction: {
    params: { spendBundle: SpendBundle };
    result: TransactionResp[];
  };
  createOffer: {
    params: {
      offerAssets: Array<{ assetId: Hex | ""; amount: Amount }>;
      requestAssets: Array<{ assetId: Hex | ""; amount: Amount }>;
      fee?: Amount;
    };
    result: { id: Hex; offer: string };
  };
  takeOffer: {
    params: { offer: string; fee?: Amount };
    result: { id: Hex };
  };
}

export type ChiaMethod = keyof ChiaMethodMap;

export interface RequestArguments<M extends ChiaMethod = ChiaMethod> {
  method: M;
  params?: ChiaMethodMap[M]["params"];
}

export type ChiaEvent = "chainChanged" | "accountChanged";

export interface ChiaWallet {
  // Identity
  readonly name: string;
  readonly version: string;
  readonly apiVersion: string;
  readonly isGoby: true;
  readonly isOzone?: true;

  // Transport
  request<M extends ChiaMethod>(args: RequestArguments<M>): Promise<ChiaMethodMap[M]["result"]>;

  // Events
  on(event: ChiaEvent, listener: (...args: any[]) => void): void;
  off?(event: ChiaEvent, listener: (...args: any[]) => void): void;
  removeListener?(event: ChiaEvent, listener: (...args: any[]) => void): void;

  // Optional accessors
  readonly chainId?: ChainId;
  readonly selectedAddress?: string;
  isConnected?(): boolean;
}

declare global {
  interface Window {
    chia?: ChiaWallet;
    ozone?: ChiaWallet;
  }
}

// ─── Wire envelope (page <-> content <-> background) ─────────────────────────

export const PAGE_TARGET = "ozone-inpage" as const;
export const CONTENT_TARGET = "ozone-content" as const;

export interface PageRequestMessage<M extends ChiaMethod = ChiaMethod> {
  target: typeof CONTENT_TARGET;
  id: number;
  origin: string;
  method: M;
  params?: ChiaMethodMap[M]["params"];
}

export interface PageResponseMessage<M extends ChiaMethod = ChiaMethod> {
  target: typeof PAGE_TARGET;
  id: number;
  result?: ChiaMethodMap[M]["result"];
  error?: { code: number; message: string; data?: unknown };
}

export interface PageEventMessage {
  target: typeof PAGE_TARGET;
  event: ChiaEvent;
  payload: unknown;
}

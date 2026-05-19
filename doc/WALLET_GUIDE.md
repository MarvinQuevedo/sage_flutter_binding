# Sage Flutter — Wallet Usage Guide

How to build a wallet UI with this binding, screen by screen. The flows mirror
Sage's own Tauri/React app (`vendor/sage/src/pages/*`), adapted to the
**in-process** model of this binding.

> Every call is `sage.api.<method>(<Request>)` (typed) or
> `sage.callJson('<endpoint>', {...})` (raw). Field names/types per endpoint are
> in [API.md](API.md). Amounts (`amount`, `fee`) are **mojos as strings**
> (`BigInt` in the typed API): XCH precision 12, CAT precision 3.

---

## 1. Lifecycle (differs from Sage's Tauri app)

Sage's desktop calls a Tauri `initialize` command, then relies on push
**events** (`events.syncEvent`) to refresh screens. This binding has neither:

| Sage Tauri | This binding |
|---|---|
| `initialize` command | `SageClient.newInstance(dataDir:)` — runs `Sage::new` + `initialize` + `switch_wallet` internally. Call once at app start. |
| `switch_wallet` command | Internal — `login`/`logout` call it for you. |
| `events.syncEvent` push updates | **No event stream yet.** Screens must **poll** (see cadence below). |
| `validate_address` command | Use the `check_address` endpoint. |
| `network_config` / `set_network_override` / `default_wallet_config` / `move_key` commands | **Not exposed** (Tauri-only, not Sage endpoints). Use `get_network`/`get_networks`/`set_network` for networks; wallet ordering is not available. |

**Bootstrap sequence:**

```dart
await SageBinding.init();                       // load native lib (once)
final dir = await getApplicationSupportDirectory();
final sage = await SageClient.newInstance(      // = initialize + switch_wallet
    dataDir: '${dir.path}/sage');
final keys = await sage.api.getKeys();          // wallet list (Login screen)
```

**Polling cadence (replace Sage's events):**

| Data | Endpoint | Suggested poll |
|---|---|---|
| Sync progress / balance | `get_sync_status` | every 3–5 s while a wallet screen is open |
| Token balances | `get_cats` + `get_token{asset_id:null}` | on open + every 10–15 s, or after an action |
| Lists (nfts/dids/txs/offers/coins) | their `get_*` | on open + after a related action |

A typed `SyncEvent` stream to Dart is a planned addition; until then, poll.

**Preconditions that bite:**
- Most endpoints need an active wallet → call `login{fingerprint}` first.
- A freshly imported wallet has **0 derivations** → `get_sync_status` throws
  `Wallet error: Insufficient derivations`. Fix: pass `derivation_index` to
  `import_key`, **and/or** call `increase_derivation_index{index, hardened,
  unhardened}` after login (idempotent — only fills the gap). The example app
  does both.

---

## 2. Wallets & Authentication

### Wallet list (Login screen)
- **On open:** `getKeys()` → list of `KeyInfo` (name, fingerprint, kind,
  networkId). Optionally `getKey()` to detect an already-active wallet.
- **Select wallet:** `login(Login(fingerprint: k.fingerprint))` → then start
  polling `getSyncStatus()` and navigate to the wallet screen.
- **Log out:** `logout()` (clears the active wallet).
- **Delete wallet:** `deleteKey(DeleteKey(fingerprint:))` (key) or
  `deleteDatabase(DeleteDatabase(fingerprint:))` (just the synced data).
- **Force resync:** `resync(Resync(fingerprint:, deleteCoins:true, ...))`.
- _Not available:_ wallet reordering (`move_key` is Tauri-only).

### Create wallet
1. `generateMnemonic(GenerateMnemonic(use24Words: true))` → show the phrase to
   back up.
2. `importKey(ImportKey(name:, key: mnemonic, login: true, derivationIndex:
   1000))` — `derivationIndex` births the wallet with addresses.
3. Navigate to the wallet screen → poll `getSyncStatus()`.

### Import wallet
- `importKey(ImportKey(name:, key: <mnemonic|privkey|pubkey>, login: true,
  derivationIndex: 1000, hardened: true, unhardened: true))`.
- Sage accepts a 12/24-word phrase, a secret key, or a public key (watch-only;
  `hardened/unhardened` control which address sets are derived).

### Create profile (DID)
- `createDid(CreateDid(name:, fee:))` → returns a transaction; submit (see
  Transactions). DIDs then appear via `getDids()`.

---

## 3. Wallet overview & tokens

### Overview / balance
- Poll `getSyncStatus()` → `GetSyncStatusResponse`: `selectableBalance`
  (spendable XCH mojos), `receiveAddress`, `syncedCoins`/`totalCoins`,
  `checkedFiles`/`totalFiles`, `unhardenedDerivationIndex`,
  `hardenedDerivationIndex`, `unit{ticker,precision}`. Format balance with
  `unit.precision`.

### Token list
- **On open:** `getToken(GetToken(assetId: null))` for XCH +
  `getCats()` → `List<TokenRecord>` (name, ticker, assetId, balance,
  selectableBalance, precision, visible, iconUrl).
- **Refresh a CAT:** `resyncCat(ResyncCat(assetId:))`.
- **Show/hide a CAT:** `updateCat(UpdateCat(record:))` with `visible` toggled.

### Token detail (per CAT)
- `getToken(GetToken(assetId:))` for details; `getCoins(GetCoins(assetId:,
  offset:0, limit:100))` for that CAT's coins (each `CoinRecord`:
  coinId, amount, address, spentHeight/createdHeight).
- **Combine coins:** `combine(Combine(coinIds:[...], fee:))`.
- **Split a coin:** `split(Split(coinIds:[...], outputCount:, fee:))`.

### Issue a new CAT
- `issueCat(IssueCat(name:, ticker:, amount:, fee:))` (amount in the new
  token's mojos, precision 3).

---

## 4. Send

`Send` handles XCH and CATs, single and bulk.

- **Validate recipient (client-ish):** `checkAddress(CheckAddress(address:))`
  before sending (replaces Sage's Tauri `validate_address`).
- **Send XCH:** `sendXch(SendXch(address:, amount:, fee:, autoSubmit: true,
  memos?, clawback?))`.
- **Bulk XCH:** `bulkSendXch(BulkSendXch(addresses:[...], amount:, fee:))`.
- **Send CAT:** `sendCat(SendCat(assetId:, address:, amount:, fee:,
  autoSubmit: true, memos?, clawback?))` — amount in the CAT's precision.
- **Bulk CAT:** `bulkSendCat(BulkSendCat(assetId:, addresses:[...], amount:,
  fee:))`.

All return a `TransactionResponse` (`summary.fee`, `summary.inputs`,
`coinSpends`). With `autoSubmit: true` it is broadcast; otherwise sign +
submit manually (see Transactions). `memos` are hex strings; `clawback` is a
seconds timestamp.

---

## 5. NFTs

- **List:** `getNfts(GetNfts(offset:, limit:, includeHidden:, sortMode:))`.
  Group by collection: `getNftCollections(GetNftCollections(offset:, limit:,
  includeHidden:))`; by minter: `getMinterDidIds(GetMinterDidIds(offset:,
  limit:))`.
- **Detail:** `getNft(GetNft(nftId:))`. Per-NFT theme:
  `getUserTheme` / `saveUserTheme` / `deleteUserTheme`.
- **Mint:** `bulkMintNfts(BulkMintNfts(...))`.
- **Transfer:** `transferNfts(TransferNfts(nftIds:[...], address:, fee:))`.
- **Assign to DID:** `assignNftsToDid(AssignNftsToDid(nftIds:[...], didId:,
  fee:))`.
- **Edit collection:** `getNftCollection(...)` → `updateNftCollection(...)`.
- **Update / redownload:** `updateNft(...)`, `redownloadNft(...)`.

---

## 6. DIDs / Profiles

- **List:** `getDids()` → `List<DidRecord>`.
- **Create:** `createDid(CreateDid(name:, fee:))`.
- **Transfer:** `transferDids(TransferDids(didIds:[...], address:, fee:))`.
- **Update metadata:** `updateDid(UpdateDid(didId:, ...))`.
- **Normalize:** `normalizeDids(NormalizeDids(...))`.

---

## 7. Offers & Swap

- **List saved:** `getOffers(GetOffers())`; one: `getOffer(GetOffer(offerId:))`;
  by asset: `getOffersForAsset(...)`.
- **Create:** `makeOffer(MakeOffer(offeredAssets:[...], requestedAssets:[...],
  fee:, expiresAtSecond?))` → returns an offer string.
- **Inspect an incoming offer:** `viewOffer(ViewOffer(offer:))` → summary
  without accepting.
- **Accept:** `takeOffer(TakeOffer(offer:, fee:))`.
- **Save / import:** `importOffer(ImportOffer(offer:))`.
- **Cancel / delete:** `cancelOffer(CancelOffer(offerId:))` /
  `cancelOffers(...)` (on-chain) and `deleteOffer(DeleteOffer(offerId:))`
  (local only).
- **Combine:** `combineOffers(CombineOffers(offers:[...]))`.
- A "Swap" screen is just a guided `makeOffer`/`takeOffer` over two assets
  (use `getCats`/`getToken` to populate the asset pickers).

---

## 8. Options

- **List:** `getOptions(GetOptions(offset:, limit:))`; one:
  `getOption(GetOption(optionId:))`.
- **Mint:** `mintOption(MintOption(...))`.
- **Exercise:** `exerciseOptions(ExerciseOptions(optionIds:[...], fee:))`.
- **Transfer:** `transferOptions(TransferOptions(optionIds:[...], address:,
  fee:))`.

---

## 9. Transactions

- **History:** `getTransactions(GetTransactions(offset:, limit:,
  ascending:false))` (paginate; supports a search/`findValue`).
- **Detail:** `getTransaction(GetTransaction(height:))`.
- **Pending:** `getPendingTransactions()`.
- **Manual build/sign/submit** (when not using `autoSubmit`):
  `createTransaction` → `signCoinSpends` (or `viewCoinSpends` to preview) →
  `submitTransaction`. WalletConnect-style instant submit:
  `sendTransactionImmediately` (see §12).
- **Clawback:** `finalizeClawback(FinalizeClawback(...))`.

### External signer (Tangem hardware card)

Import the card's BLS public key as the wallet `key` (watch-only). Sage
already curries it into the **`p2_delegated_conditions` ("arbor") puzzle** —
the exact puzzle a Tangem card spends — and syncs that address, so balance,
coins and history work normally. Only signing is external. Flow:

1. Build with `autoSubmit: false` (e.g. `sendXch`/`sendCat`) → `coinSpends`.
2. `requiredSignatures(RequiredSignatures(coinSpends:))` →
   `signatures: [{publicKey, message}]` (consensus-correct AGG_SIG messages).
3. Sign each `message` on the card over NFC (the card key == `publicKey`).
4. `submitWithSignatures(SubmitWithSignatures(coinSpends:, signatures:[...],
   autoSubmit:true))` — Sage BLS-aggregates the card signatures, builds the
   spend bundle, and broadcasts. Returns the signed `spendBundle`.

In-process `signCoinSpends` is **not** used here (no secret key on file);
`requiredSignatures` + `submitWithSignatures` replace it for card wallets.

---

## 10. Addresses

- **Derived addresses:** `getDerivations(GetDerivations(offset:, limit:,
  hardened:false))` → `DerivationRecord` (address, index, publicKey).
- **Generate more:** `increaseDerivationIndex(IncreaseDerivationIndex(index:,
  hardened:true, unhardened:true))` — also the fix for "Insufficient
  derivations".
- **Check ownership:** `checkAddress(CheckAddress(address:))`.

---

## 11. Peers & Settings

- **Peers:** `getPeers()`, `addPeer(AddPeer(ip:))`,
  `removePeer(RemovePeer(ip:))`, `setDiscoverPeers(...)`,
  `setTargetPeers(...)`.
- **Networks:** `getNetworks()`, `getNetwork()`, `setNetwork(SetNetwork(...))`.
  (Sage's `network_config`/`set_network_override` Tauri commands are not
  exposed — use these endpoints.)
- **Database:** `getDatabaseStats()`,
  `performDatabaseMaintenance(PerformDatabaseMaintenance())`.
- **Wallet settings:** `setChangeAddress(SetChangeAddress(address:))`,
  `setDeltaSync(SetDeltaSync(...))`.
- **Themes:** `getUserThemes()`, `saveUserTheme(...)`,
  `deleteUserTheme(...)`, `getUserTheme(GetUserTheme(nftId:))`.

---

## 12. WalletConnect endpoints (the 5 ex-"Tauri" ones)

Now first-class in this binding (typed + in the Console). These power
WalletConnect / dApp integrations:

- `filterUnlockedCoins(FilterUnlockedCoins(coinIds:[...]))` → which coins are
  spendable (not locked in offers).
- `getAssetCoins(GetAssetCoins(type?, assetId?, includedLocked?, offset?,
  limit?))` → spendable coins for an asset (note: this request uses
  **camelCase** JSON keys, e.g. `assetId`, `includedLocked`, `type`).
- `signMessageByAddress(SignMessageByAddress(message:, address:))` and
  `signMessageWithPublicKey(SignMessageWithPublicKey(message:, publicKey:))` →
  message signing for dApp auth.
- `sendTransactionImmediately(SendTransactionImmediately(spendBundle:))` →
  broadcast a spend bundle now (used after building/signing externally).

These need an active (logged-in) wallet; `sign_message_*` use the wallet's
secret key (held by Sage's in-process keychain).

---

## 13. Conventions & gotchas

- **Amounts:** pass mojos as a string (`"1000000000000"` = 1 XCH). The typed
  API exposes them as `BigInt` and serializes to string (lossless). Never use
  Dart `double` for amounts.
- **Errors:** Sage returns the Rust error string (e.g. `Wallet error:
  Insufficient funds`, `missing field 'offset'`). These are *correct
  validation responses*, not binding bugs — surface them to the user.
- **Always `login` first** for wallet-scoped endpoints; call
  `increaseDerivationIndex` once after login on a wallet that may have 0
  derivations.
- **No push events:** poll (see §1). After a mutating action
  (`send_*`, `combine`, `split`, `make_offer`, …) immediately re-fetch the
  affected list + `getSyncStatus()`.
- **Tauri-only commands not available:** `initialize` (use `newInstance`),
  `validate_address` (use `checkAddress`), `network_config` /
  `set_network_override` (use `getNetwork`/`setNetwork`),
  `default_wallet_config`, `move_key`. Everything that is a real Sage endpoint
  (105 total) is exposed.

See the example app ([example/lib/main.dart](../example/lib/main.dart)) for a
working Wallet / Tokens / Send / Console implementation, and
[API.md](API.md) for every endpoint's request/response fields.

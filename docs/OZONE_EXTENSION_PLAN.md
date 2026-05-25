# Ozone Extension — Plan de Implementación

> **Estado:** Planificación. Decisiones de arquitectura confirmadas, listo para empezar.
> **Fecha:** 2026-05-25
> **Autor:** Marvin + Claude
> **Repos a crear:**
> - `~/Projects/Ozone/ozone-extension/` (nuevo)
> - `~/Projects/Ozone/fork/sage-web/` (clon independiente de `xch-dev/sage`)

---

## 0. TL;DR

Construir una extensión de navegador (Chrome MV3) que sea una wallet de Chia minimalista, compatible con el protocolo Goby (CHIP-0002), basada en un fork de Sage compilado a WASM. El sync se hace contra `coinset.org` (HTTP REST) en lugar de peers P2P, porque las extensiones de Chrome no pueden conectar a peers Chia con certificados auto-firmados.

**Stack final:**
- **Extensión:** WXT + React 19 + TypeScript + Vite
- **Wallet core:** fork de Sage compilado a `wasm32-unknown-unknown` vía `wasm-bindgen`
- **Sync:** REST contra `api.coinset.org` (con fallback a `kraken.fireacademy.io/leaflet`)
- **Storage:** IndexedDB (vía trait `Storage` abstraída del backend SQLite de Sage)
- **Protocolo dApp:** `window.chia` (Goby-compatible / CHIP-0002)
- **Alcance MVP:** Paridad completa con Sage (XCH + CAT + NFT + DID + Offers)

---

## 1. Decisiones de diseño (confirmadas)

| Decisión | Elegido | Por qué |
|----------|---------|---------|
| Repo extensión | `ozone-extension` en `~/Projects/Ozone/` | Consistencia con familia Ozone (ozone_wallet_app, sage_flutter_binding) |
| Fork de sage | Clon separado `fork/sage-web` | Aísla del binding mobile; permite divergencia limpia + workflow de rebase independiente contra `xch-dev/sage` |
| UI stack | WXT + React 19 + TS | Reutilizamos componentes/patrones de Ozone; React 19 + server-components no aplica en extensión pero JSX y hooks sí |
| Alcance sync MVP | Paridad completa Sage | Vale el esfuerzo extra para no tener que volver a refactorizar |

---

## 2. Arquitectura general

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DAPP (página web)                            │
│  window.chia.request({method:'connect'}) ───────┐                   │
└──────────────────────────────────────────────────┼──────────────────┘
                                                   │ postMessage
┌──────────────────────────────────────────────────▼──────────────────┐
│                EXTENSION CONTENT SCRIPT (isolated world)             │
│  ─ inyecta inpage.js (en MAIN world) que define window.chia          │
│  ─ bridge: window.postMessage <─> chrome.runtime.sendMessage         │
└──────────────────────────────────────────────────┬──────────────────┘
                                                   │ chrome.runtime
┌──────────────────────────────────────────────────▼──────────────────┐
│           EXTENSION SERVICE WORKER (background, MV3)                 │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │   JSON-RPC router (CHIP-0002 method map)                      │  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │   Sage WASM module (wallet-wasm)                              │  │
│  │   ─ Derivations, signing, offer build/take, NFT/DID parse    │  │
│  │   ─ SyncManager con CoinsetBackend                            │  │
│  │   ─ Storage trait → bound a IndexedDB vía wasm-bindgen        │  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │   Approval queue (popup launcher)                             │  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │   chrome.alarms (sync loop) + chrome.storage (sesión + persist) │
│  └──────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┬──────────────────┘
                                                   │ fetch (CORS)
┌──────────────────────────────────────────────────▼──────────────────┐
│              api.coinset.org (Chia Full Node RPC)                    │
│   get_coin_records_by_puzzle_hashes / _by_hint / _by_names           │
│   get_puzzle_and_solution / get_coin_record_by_name / push_tx        │
│   get_blockchain_state / get_block_record_by_height                  │
└─────────────────────────────────────────────────────────────────────┘
```

**Puntos clave:**
- El service worker es el "dueño" de la wallet. UI (popup, approval) es estríctamente cliente.
- Toda crypto/CLVM/firma ocurre en WASM dentro del service worker.
- La extensión nunca habla TCP directo a peers. Solo HTTPS a `api.coinset.org`.

---

## 3. Repositorios

### 3.1 `fork/sage-web` (nuevo, clon de xch-dev/sage)

**Estructura de remotes:**
```bash
cd ~/Projects/Ozone/fork/sage-web
git remote -v
# origin    git@github.com:Ozone-Wallet/sage-web.git  (push/fetch)
# upstream  https://github.com/xch-dev/sage.git       (fetch)
```

**Branch strategy:**
- `main` = upstream `xch-dev/sage:main` (espejo, sin nuestros parches)
- `web/coinset-sync` = donde vive nuestro trabajo
- Rebase periódico de `web/coinset-sync` sobre `upstream/main` (mismo workflow que `vendor/sage` en el binding)

**Serie de parches (commits ordenados):**

1. **`feat(sync): introduce SyncBackend trait`**
   - `crates/sage-wallet/src/sync_backend/mod.rs`: trait + tipos compartidos
   - `crates/sage-wallet/src/sync_backend/peer.rs`: implementación que envuelve el `WalletPeer` actual
   - Refactor `SyncManager::new(...)` → toma `Arc<dyn SyncBackend>` en lugar de `Vec<Peer>`
   - **Validación:** `cargo test -p sage-wallet` debe pasar; comportamiento desktop/mobile inalterado

2. **`feat(sync): CoinsetBackend implementation`**
   - `crates/sage-wallet/src/sync_backend/coinset.rs`
   - `crates/sage-wallet/Cargo.toml`: feature `coinset-sync` con deps `reqwest = { default-features=false, features = ["json", "rustls-tls"] }`
   - Cliente HTTP estructurado con `serde` para todos los `*Request` / `*Response`
   - Manejo de errores: `MempoolInclusionStatus` enum, `structuredError.code` parseado

3. **`feat(sync): polling sync loop`**
   - `crates/sage-wallet/src/sync_manager/coinset_loop.rs`
   - Algoritmo: peak → diff puzzle_hashes batched → diff hints → diff known unspent coins
   - Reorg safety: `start_height = max(0, last_synced - 32)`
   - Emite `CoinStateUpdate` sintético al pipeline existente de Sage

4. **`refactor(db): Storage trait sobre sage-database`**
   - `crates/sage-database/src/storage.rs`: trait `Storage` con métodos exactos que hoy expone `sage_database::Database`
   - `crates/sage-database/src/sqlite/`: impl `SqliteStorage` (código actual movido)
   - `crates/sage-database/Cargo.toml`: feature `sqlite` default-on; sin esta feature el crate solo expone el trait
   - **Sin breaking changes** para los consumidores nativos

5. **`feat(wasm): wasm32-unknown-unknown target + bindings`**
   - `crates/sage-wasm/`: nuevo crate, `cdylib`, expone los 110 endpoints de `sage-api` vía `wasm-bindgen`
   - `cfg(target_arch = "wasm32")` gates en todo lo que importe tokio-net o sqlite
   - `JsCallbackStorage` impl en `sage-wasm` que delega a callbacks JS (IndexedDB del lado TS)
   - Build script: `wasm-pack build --target web --out-dir ../../pkg --features coinset-sync,wasm`

6. **`feat(api): high-level commands sobre coinset backend`**
   - Tests de integración: make_offer, take_offer, transfer_nft, bulk_mint_nfts, send_xch, send_cat
   - Estos endpoints ya existen en sage-api; este parche es validación + bug fixes específicos del backend coinset

**Dependencias críticas (Fase 0):**
- ¿`chia-wallet-sdk 0.33` compila a `wasm32-unknown-unknown`?
- ¿Hay que forkear también `chia-wallet-sdk`?
- Investigación en background (agente `a1682fbf07963b67e`) lo está validando.

### 3.2 `ozone-extension` (nuevo)

**Estructura:**
```
ozone-extension/
├── package.json
├── pnpm-workspace.yaml
├── tsconfig.base.json
├── .gitmodules                  # sage-web como submodule
├── vendor/
│   └── sage-web/                # git submodule -> Ozone-Wallet/sage-web
├── packages/
│   ├── wallet-wasm/             # paquete generado por wasm-pack
│   │   ├── package.json         # name: "@ozone/wallet-wasm"
│   │   ├── sage_wasm.js
│   │   ├── sage_wasm_bg.wasm
│   │   └── sage_wasm.d.ts
│   ├── storage-idb/             # impl IndexedDB de la trait Storage
│   │   ├── src/
│   │   │   ├── index.ts         # export class IdbStorage implements WasmStorage
│   │   │   ├── schema.ts        # versión de esquema + migraciones
│   │   │   └── tables.ts        # coins, derivations, txs, offers, nfts, dids
│   │   └── package.json
│   ├── coinset-client/          # opcional: pequeño wrapper TS para debugging fuera de Rust
│   │   └── src/index.ts
│   ├── goby-provider/           # inpage.js + tipos
│   │   ├── src/
│   │   │   ├── inpage.ts        # se inyecta en MAIN world
│   │   │   ├── content-bridge.ts
│   │   │   ├── types.ts         # CHIP-0002 + Goby ext typings
│   │   │   └── errors.ts        # códigos 4000-4029
│   │   └── package.json
│   └── extension/               # la app WXT
│       ├── wxt.config.ts
│       ├── entrypoints/
│       │   ├── background.ts    # service worker
│       │   ├── content.ts       # content script
│       │   ├── popup/
│       │   │   ├── App.tsx
│       │   │   ├── routes/
│       │   │   │   ├── Lock.tsx
│       │   │   │   ├── Home.tsx           # balances XCH + CAT
│       │   │   │   ├── Send.tsx
│       │   │   │   ├── Receive.tsx
│       │   │   │   ├── Nfts.tsx
│       │   │   │   ├── Offers.tsx
│       │   │   │   ├── Activity.tsx
│       │   │   │   └── Settings.tsx
│       │   │   └── components/
│       │   ├── approve.html     # ventana de aprobación de firmas
│       │   └── onboarding.html  # primer-uso (importar / crear seed)
│       ├── public/
│       │   └── icons/
│       └── package.json
└── docs/
    ├── ARCHITECTURE.md
    ├── COINSET_SYNC.md
    └── GOBY_PROTOCOL.md
```

**Scripts npm clave:**
```json
{
  "scripts": {
    "wasm:build": "cd vendor/sage-web && wasm-pack build crates/sage-wasm --target web --out-dir ../../../packages/wallet-wasm --features coinset-sync,wasm",
    "wasm:opt": "wasm-opt -Oz -o packages/wallet-wasm/sage_wasm_bg.wasm packages/wallet-wasm/sage_wasm_bg.wasm",
    "dev": "wxt --filter @ozone/extension",
    "build": "pnpm wasm:build && pnpm wasm:opt && wxt build --filter @ozone/extension",
    "zip": "wxt zip --filter @ozone/extension"
  }
}
```

---

## 4. Sync con coinset.org — Especificación completa

### 4.1 Endpoint inventory (verificado en vivo 2026-05-25)

`api.coinset.org` es passthrough del Full Node RPC de `chia-blockchain`. Confirmado vía traceback Python leakeado que apunta a `chia/full_node/full_node_rpc_api.py`.

**Reglas de transporte:**
- Method: `POST` siempre (excepto `OPTIONS` para CORS preflight)
- URL: `https://api.coinset.org/<rpc_name>` (sin prefix `/api`, sin versión)
- Content-Type: `application/json`
- Body: objeto JSON (vacío `{}` válido para endpoints sin args)
- Hex: hashes serializados como `"0x" + 64 hex chars`
- Amounts: JSON numbers (uint64) — **deserializar en Rust como u64, exponer a JS como string** (>2^53 mojos perdería precisión)
- Height type: uint32
- CORS: `Access-Control-Allow-Origin: *` (perfect para extensión)

**Tabla de endpoints (verificados live):**

| Endpoint | Uso |
|----------|-----|
| `get_blockchain_state` | peak, sync, espacio, mempool stats |
| `get_network_info` | `{network_name, network_prefix}` |
| `get_network_space` | requiere `older` y `newer` distintos |
| `get_block` | full FullBlock por header_hash |
| `get_blocks` | rango `[start, end)`, opciones de exclude |
| `get_block_record` | por header_hash |
| `get_block_record_by_height` | por height |
| `get_block_records` | rango `[start, end)` |
| `get_block_spends` | todos los coin_spend de un transaction block |
| `get_block_spends_with_conditions` | + condiciones CLVM resueltas |
| `get_additions_and_removals` | por header_hash → `additions[]`, `removals[]` |
| `get_aggsig_additional_data` | AGG_SIG_ME extra data (firma offline) |
| `get_fee_estimate` | requiere `cost` + `target_times` |
| `get_coin_record_by_name` | single por coin_id |
| `get_coin_records_by_names` | batch por coin_id[] |
| `get_coin_records_by_puzzle_hash` | core wallet sync |
| **`get_coin_records_by_puzzle_hashes`** | **batch — preferir siempre** |
| `get_coin_records_by_hint` | CATs/NFTs receiving |
| `get_coin_records_by_parent_ids` | walking singleton/NFT lineages |
| `get_puzzle_and_solution` | requiere `coin_id` + `height = spent_block_index` |
| `push_tx` | submit SpendBundle |
| `get_mempool_item_by_tx_id` | by spend bundle hash |
| `get_mempool_items_by_coin_name` | qué mempool sb afecta a un coin |
| `get_all_mempool_items` | dump completo (¡grande!) |

**NO expuestos:** `get_routes`, `get_recent_signage_point_or_eos`.

**No requiere API key. CORS abierto. Cloudflare-fronted. Sin límites observados hasta 500 req/s burst.**

### 4.2 Schemas críticos

**`get_coin_records_by_puzzle_hashes`** (batch, preferido):
```json
{
  "puzzle_hashes": ["0x...", "0x..."],
  "start_height": 0,
  "end_height": 9999999,
  "include_spent_coins": true
}
```
Response:
```json
{
  "coin_records": [
    {
      "coin": {
        "parent_coin_info": "0x...",
        "puzzle_hash": "0x...",
        "amount": 100
      },
      "coinbase": false,
      "confirmed_block_index": 1147159,
      "spent": false,
      "spent_block_index": 0,
      "timestamp": 1637034585
    }
  ],
  "success": true
}
```

**`get_coin_records_by_hint`** — mismo shape pero el `hint` es el primer elemento de 32 bytes en la memo list de `CREATE_COIN`. Confirmado:
- **CAT**: `hint` = inner_puzzle_hash del receptor (p2_delegated_or_hidden)
- **NFT**: `hint` = launcher_id (eve) o p2_inner_puzzle_hash (ownership)
- **DID**: `hint` = launcher_id

**`push_tx`** — request:
```json
{
  "spend_bundle": {
    "coin_spends": [{
      "coin": {"parent_coin_info":"0x...","puzzle_hash":"0x...","amount":1000000000},
      "puzzle_reveal": "0xff02ffff01...",
      "solution": "0xff80ffff01..."
    }],
    "aggregated_signature": "0x<96 hex bytes>"
  }
}
```
Response:
- Éxito mempool: `{"status":"SUCCESS","success":true}` o `"PENDING"`
- Rechazo mempool: `{"status":"FAILED", "error":"<Err name>", "success":true}` — códigos: `DOUBLE_SPEND`, `INVALID_FEE_LOW_FEE`, `MEMPOOL_FULL`, `MEMPOOL_CONFLICT`, `ASSERT_HEIGHT_NOW_EXCEEDS_FAILED`, `BAD_AGGREGATE_SIGNATURE`, `BLOCK_COST_EXCEEDS_MAX`, `UNKNOWN_UNSPENT`
- Error de formato: HTTP 200 + `{"success":false, "structuredError":{"code":"...","message":"..."}, "traceback":"..."}`

### 4.3 Algoritmo de sync

```rust
// Pseudocódigo (vive en crates/sage-wallet/src/sync_manager/coinset_loop.rs)

struct CoinsetSyncState {
    last_synced_height: u32,
    watched_puzzle_hashes: HashSet<Bytes32>,      // todas las derivaciones standard activas
    watched_hints: HashSet<Bytes32>,              // CAT inner_phs, NFT launcher_ids, DID launcher_ids
    unspent_coin_ids: HashSet<Bytes32>,           // coins propios marcados como no gastados
}

async fn sync_loop(backend: Arc<CoinsetBackend>, storage: Arc<dyn Storage>) {
    loop {
        let peak = backend.peak_height().await?;
        let start = state.last_synced_height.saturating_sub(32);  // reorg safety: 32 blocks

        // 1. Diff por puzzle_hash (batched, max 250 por request)
        for ph_batch in state.watched_puzzle_hashes.chunks(250) {
            let records = backend.coin_records_by_puzzle_hashes(
                ph_batch, start, peak + 1, /*include_spent*/ true
            ).await?;
            for r in records {
                storage.upsert_coin(r).await?;
                // Trigger CAT/NFT detection si tiene hint asociado
                if let Some(hint) = extract_hint(&r) {
                    classify_and_store(&r, hint, &storage).await?;
                }
            }
        }

        // 2. Diff por hint (CATs/NFTs/DIDs recibidos)
        for hint_batch in state.watched_hints.chunks(250) {
            for hint in hint_batch {
                let records = backend.coin_records_by_hint(*hint, start, peak + 1, true).await?;
                for r in records {
                    storage.upsert_coin(r).await?;
                    classify_and_store(&r, *hint, &storage).await?;
                }
            }
        }

        // 3. Re-verificar coins nuestros marcados como no gastados
        for coin_id_batch in state.unspent_coin_ids.chunks(250) {
            let records = backend.coin_records_by_names(coin_id_batch).await?;
            for r in records {
                if r.spent_block_index != 0 {
                    storage.mark_spent(r.coin_id(), r.spent_block_index).await?;
                }
            }
        }

        // 4. Gap limit: si la última puzzle hash activa tiene coins,
        //    derivar siguientes N puzzle hashes y agregarlas a watched_puzzle_hashes
        maintain_derivation_gap(&storage, /*gap_limit*/ 100).await?;

        // 5. Procesar singleton lineages (NFT updates): para cada NFT, walking parent → child
        update_singleton_lineages(&backend, &storage).await?;

        // 6. Mempool watch: para txs pendientes nuestros
        check_pending_txs(&backend, &storage).await?;

        state.last_synced_height = peak;
        storage.set_last_synced(peak).await?;

        sleep(POLL_INTERVAL).await;  // 5s activo, 60s idle
    }
}
```

**Throttling:**
- Concurrency cap: 12 in-flight requests
- Backoff exponencial en 5xx / 429: 1s, 2s, 4s, 8s, max 30s
- Detección de reorg: si en una iteración encontramos coins con `confirmed_block_index < state.last_synced_height - 32` con state cambiado, hacer full re-sync de los últimos 1000 bloques

**Detección de tipos de coin:**
```rust
fn classify_coin(coin: &Coin, puzzle_reveal: Option<&Program>) -> CoinType {
    // 1. Standard P2 (XCH directo): puzzle_hash es derivado de wallet → XCH
    // 2. CAT: puzzle_reveal matchea CAT_MOD (cat_v2.clsp) → extract asset_id (tail hash), inner_ph
    // 3. NFT: puzzle_reveal matchea NFT_STATE_LAYER_MOD → extract launcher_id, metadata, royalty
    // 4. DID: puzzle_reveal matchea DID_INNERPUZ_MOD → extract launcher_id, recovery_list
    // 5. Offer (1 of N coins of an offered spend bundle)
}
```

Las funciones de parsing (NFT_STATE_LAYER detection, CAT outer puzzle wrapping, DID singleton tracking) están todas en `chia-wallet-sdk` y `sage-wallet/src/wallet/*.rs` — son transport-agnostic, no requieren cambios para WASM.

### 4.4 Gaps semánticos vs P2P wallet protocol

| Feature P2P | Equivalente coinset | Compromiso |
|-------------|---------------------|------------|
| `CoinStateUpdate` push (real-time) | Polling cada 5-60s | Latencia adicional, aceptable para UX wallet |
| Reorg con `fork_height` explícito | Re-pull 32-bloque tail cada iter | Más bandwidth, lógica más compleja en cliente |
| Server-side filter en `RequestAdditions` (filtra additions por PH) | `get_additions_and_removals` devuelve todo el bloque | Filtrar en cliente; wasteful para bloques grandes |
| `RegisterForPhUpdates` con suscripción persistente | `watched_puzzle_hashes` set client-side | Bandwidth lineal vs O(1) push |
| Weight-proof / SPV trust-minimized | Trust en coinset.org | **Riesgo aceptado** — mitigar con multi-provider crossing-check y opción "self-host node URL" |
| Mempool push (`MempoolItemsAdded/Removed`) | `get_mempool_item_by_tx_id` poll cada 2-5s | Más requests, latencia para "tx droppeada" |
| `RequestCostInfo` | Hardcode `MAX_BLOCK_COST_CLVM/2` o read `get_constants` si disponible | Estático vs dinámico, aceptable |

### 4.5 Multi-provider fallback

| Provider | Base URL | Notas |
|----------|----------|-------|
| **coinset.org** | `https://api.coinset.org` | Primary. Sin auth. CORS abierto. |
| **FireAcademy.io (Leaflet)** | `https://kraken.fireacademy.io/leaflet/` | Fallback. Sin auth para tier público. Mismo schema. |
| **Self-hosted full node** | `https://<your-host>:8555` | Power-user. Requiere CORS proxy o config local. |

Implementar `RpcProvider` trait con `coinset_org`, `fireacademy_io`, y `custom_url`. Circuit breaker: si un provider falla 3 veces consecutivas, switch al siguiente por 60s.

---

## 5. Goby Protocol — Especificación completa

### 5.1 Detección y provider

```ts
interface ChiaWallet {
  // Identidad
  name: string;            // "Ozone" (o "Goby" si queremos máxima compat)
  version: string;
  apiVersion: string;      // "1.0.0" (CHIP-0002)
  isGoby: true;            // CRITICAL: muchos dApps checan esto

  // EIP-1193 transport (canónico)
  request<T = unknown>(args: { method: string; params?: unknown }): Promise<T>;

  // Eventos
  on(event: 'chainChanged' | 'accountChanged', listener: (...args: any[]) => void): void;
  off?(event: string, listener: Function): void;

  // Accessors opcionales
  chainId?: string;          // "mainnet" | "testnet11"
  selectedAddress?: string;  // bech32m
  isConnected?(): boolean;
}

declare global {
  interface Window {
    chia?: ChiaWallet;
    ozone?: ChiaWallet;   // alias propio + alias goby
  }
}
```

### 5.2 Métodos a implementar

**Conexión y meta (CHIP-0002):**
| Método | Params | Returns | Approval |
|--------|--------|---------|----------|
| `chainId` | — | `string` | No |
| `connect` | `{ eager?: boolean }` | `boolean` | Yes (skip si eager + previamente aprobado) |
| `walletSwitchChain` | `{ chainId: string }` | `null` | Yes |
| `walletWatchAsset` | `{ type, options: { assetId, symbol, logo? } }` | `boolean` | Yes |

**Read (post-connect, sin approval):**
| Método | Params | Returns |
|--------|--------|---------|
| `getPublicKeys` | `{ limit?, offset?, hardened? }` | `string[]` (hex pubkeys, 48 bytes G1) |
| `filterUnlockedCoins` | `{ coinNames: string[] }` | `string[]` (coin names que NO están lockeados) |
| `getAssetCoins` | `{ type, assetId, includedLocked?, offset?, limit? }` | `SpendableCoin[]` |
| `getAssetBalance` | `{ type, assetId }` | `{ confirmed, spendable, spendableCoinCount }` |

**Signing (con approval):**
| Método | Params | Returns | Notas |
|--------|--------|---------|-------|
| `signCoinSpends` | `{ coinSpends: CoinSpend[]; partialSign?: boolean }` | `string` (BLS agg sig hex) | Doble-confirma `AGG_SIG_UNSAFE` en UI |
| `signMessage` | `{ message: string; publicKey: string }` | `string` (BLS sig hex) | Augmented Scheme |

**Goby extensions (con approval):**
| Método | Params | Returns |
|--------|--------|---------|
| `transfer` | `{ to, amount, assetId, memos?, fee? }` | `{ id: string }` |
| `sendTransaction` | `{ spendBundle: SpendBundle }` | `TransactionResp[]` |
| `createOffer` | `{ offerAssets, requestAssets, fee? }` | `{ id, offer }` |
| `takeOffer` | `{ offer, fee? }` | `{ id: string }` |

**Códigos de error CHIP-0002:**
| Code | Name | Cuándo |
|------|------|--------|
| 4000 | InvalidParamsError | params falló validación schema |
| 4001 | UnauthorizedError | dApp no conectada |
| 4002 | UserRejectedRequestError | usuario click Reject |
| 4003 | SpendableBalanceExceededError | no hay mojos suficientes unlocked |
| 4004 | MethodNotFoundError | método desconocido |
| 4005 | NoSecretKeyError | wallet no tiene la sk de un pubkey requerido |
| 4029 | LimitExceedError | rate-limited |

### 5.3 Wire protocol (page ↔ extension)

```
dApp page                  inpage.js (MAIN world)         content.ts (ISOLATED)         background.ts (SW)
   │                            │                              │                          │
   │ window.chia.request({})    │                              │                          │
   │ ─────────────────────────► │                              │                          │
   │                            │ window.postMessage(          │                          │
   │                            │  {target:'ozone-content',    │                          │
   │                            │   id, method, params, origin})                          │
   │                            │ ─────────────────────────────► │                        │
   │                            │                              │ chrome.runtime           │
   │                            │                              │  .sendMessage({           │
   │                            │                              │   from: 'content',        │
   │                            │                              │   origin, id, ... })      │
   │                            │                              │ ─────────────────────────►│
   │                            │                              │                          │ ► CHIP-0002 router
   │                            │                              │                          │ ► permission check
   │                            │                              │                          │ ► approval popup (if needed)
   │                            │                              │                          │ ► WASM call
   │                            │                              │ ◄────────────────────────│
   │                            │ ◄─postMessage{               │                          │
   │                            │   target:'ozone-inpage',     │                          │
   │                            │   id, result | error }       │                          │
   │ Promise resolves/rejects   │                              │                          │
   │ ◄──────────────────────────│                              │                          │
```

**Detalles:**
- `id`: counter monotónico per-tab (o UUID v4)
- `origin`: `location.origin` del documento, asignado en inpage.ts antes de enviar (el SW verifica que coincida con el `sender.origin` que chrome reporta)
- Permission storage: `chrome.storage.local`, key `permissions[origin][fingerprint] = { connectedAt, methods }`
- Approval UI: `chrome.windows.create({ url: 'approve.html?reqId=...', type: 'popup', width: 400, height: 600 })`

### 5.4 Mapping CHIP-0002 → sage-api endpoints

Aprovechamos los 110 endpoints existentes de `sage-api`. Mapping (parcial, ampliar al implementar):

```ts
// packages/extension/src/lib/rpc-router.ts (pseudocódigo)
const RPC_MAP: Record<string, { sageEndpoint: string; transform?: Fn; needsApproval: boolean }> = {
  // CHIP-0002 core
  'chainId':                { sageEndpoint: 'get_network',         needsApproval: false, transform: r => r.network_id },
  'connect':                { sageEndpoint: '__internal_connect',  needsApproval: true },
  'getPublicKeys':          { sageEndpoint: 'get_derivations',     needsApproval: false },
  'filterUnlockedCoins':    { sageEndpoint: 'filter_unlocked_coins', needsApproval: false },
  'getAssetCoins':          { sageEndpoint: 'get_spendable_coins', needsApproval: false },
  'getAssetBalance':        { sageEndpoint: 'get_sync_status',     needsApproval: false },
  'signCoinSpends':         { sageEndpoint: 'sign_coin_spends',    needsApproval: true },
  'signMessage':            { sageEndpoint: 'sign_message_by_public_key', needsApproval: true },

  // Goby ext
  'transfer':               { sageEndpoint: 'send_xch'/'send_cat', needsApproval: true },
  'sendTransaction':        { sageEndpoint: 'submit_transaction',  needsApproval: true },
  'createOffer':            { sageEndpoint: 'make_offer',          needsApproval: true },
  'takeOffer':              { sageEndpoint: 'take_offer',          needsApproval: true },
  'walletSwitchChain':      { sageEndpoint: 'switch_network',      needsApproval: true },
  'walletWatchAsset':       { sageEndpoint: 'add_cat',             needsApproval: true },
};
```

Reusar las Zod schemas de `vendor/sage/src/walletconnect/commands.ts` para validar params.

### 5.5 Diferencias clave vs EVM

1. **Coin set model**: cada coin es único e inmutable. No hay account-balance. UI debe mostrar coin selection cuando sea relevante.
2. **Aggregated BLS signing**: una sola firma para todo el bundle (vs ECDSA per-tx).
3. **No nonces**: prevención de replay vía coin uniqueness + `AGG_SIG_ME`.
4. **Fee = mojos reservados**, no gas price × gas limit.
5. **Amounts en mojos**: 1 XCH = 1e12 mojos. >9k XCH excede `Number.MAX_SAFE_INTEGER`. **Usar string internamente**, aceptar number | string en input.
6. **dApp típicamente construye el bundle**: el dApp llama `getAssetCoins`, construye `CoinSpend[]`, lo manda al wallet solo para firmar (`signCoinSpends`). Diferente del flujo MetaMask "manda `{to, value, data}` al wallet".
7. **Approval UI crítica**: hay que decodificar `CoinSpend[]` → XCH/CAT/NFT moves humano-legibles, sino es phishing-bait.
8. **Coin locking**: tras `signCoinSpends`, los coins firmados quedan "locked" hasta confirmarse on-chain o expirar timeout. Sin esto, el dApp puede double-spend en retries.

---

## 6. WASM build pipeline

### 6.1 Crate `sage-wasm` (nuevo en `fork/sage-web`)

`crates/sage-wasm/Cargo.toml`:
```toml
[package]
name = "sage-wasm"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib", "rlib"]

[features]
default = ["coinset-sync"]
coinset-sync = ["sage-wallet/coinset-sync"]

[dependencies]
sage-wallet = { path = "../sage-wallet", default-features = false, features = ["coinset-sync", "wasm"] }
sage-database = { path = "../sage-database", default-features = false }
sage-api = { path = "../sage-api" }
wasm-bindgen = "0.2"
wasm-bindgen-futures = "0.4"
serde = { version = "1", features = ["derive"] }
serde-wasm-bindgen = "0.6"
js-sys = "0.3"
web-sys = { version = "0.3", features = ["console"] }
getrandom = { version = "0.2", features = ["js"] }
console_error_panic_hook = "0.1"
```

`crates/sage-wasm/src/lib.rs`:
```rust
use wasm_bindgen::prelude::*;

#[wasm_bindgen(start)]
pub fn main() {
    console_error_panic_hook::set_once();
}

#[wasm_bindgen]
pub struct Sage {
    inner: Arc<RwLock<sage::Sage>>,
}

#[wasm_bindgen]
impl Sage {
    #[wasm_bindgen(constructor)]
    pub fn new(storage_callbacks: JsValue) -> Result<Sage, JsValue> {
        let storage = JsCallbackStorage::from_js(storage_callbacks)?;
        let inner = sage::Sage::new_with_storage(Arc::new(storage))?;
        Ok(Sage { inner })
    }

    // Para cada endpoint de sage-api, generar un wasm_bindgen export:
    #[wasm_bindgen]
    pub async fn login(&self, req: JsValue) -> Result<JsValue, JsValue> {
        let req: LoginReq = serde_wasm_bindgen::from_value(req)?;
        let res = self.inner.read().await.login(req).await?;
        Ok(serde_wasm_bindgen::to_value(&res)?)
    }

    // ... ~110 más, generados con macro
}
```

**Macro para generar los 110 endpoints automáticamente:**
```rust
// crates/sage-wasm/src/macro.rs
macro_rules! wasm_endpoint {
    ($name:ident, $req:ty, $res:ty) => {
        #[wasm_bindgen]
        impl Sage {
            #[wasm_bindgen]
            pub async fn $name(&self, req: JsValue) -> Result<JsValue, JsValue> {
                let req: $req = serde_wasm_bindgen::from_value(req)?;
                let res = self.inner.read().await.$name(req).await
                    .map_err(|e| JsValue::from_str(&e.to_string()))?;
                Ok(serde_wasm_bindgen::to_value(&res)?)
            }
        }
    };
}

wasm_endpoint!(login, LoginReq, LoginResp);
wasm_endpoint!(send_xch, SendXchReq, SendXchResp);
// ... etc
```

### 6.2 Storage callback interface

`packages/storage-idb/src/index.ts`:
```ts
import { openDB, IDBPDatabase } from 'idb';

export interface WasmStorageCallbacks {
  getCoin(coinId: string): Promise<Uint8Array | null>;
  putCoin(coinId: string, data: Uint8Array): Promise<void>;
  listCoinsByPuzzleHash(ph: string): Promise<Uint8Array[]>;
  // ... ~30 más métodos, uno por cada query distinto de sage-database
}

export class IdbStorage implements WasmStorageCallbacks {
  private db: IDBPDatabase;

  static async open(walletId: string): Promise<IdbStorage> {
    const db = await openDB(`ozone-wallet-${walletId}`, 1, {
      upgrade(db) {
        db.createObjectStore('coins', { keyPath: 'coinId' });
        db.createObjectStore('derivations', { keyPath: ['walletId', 'index', 'hardened'] });
        db.createObjectStore('txs', { keyPath: 'txId' });
        db.createObjectStore('offers', { keyPath: 'offerId' });
        db.createObjectStore('nfts', { keyPath: 'launcherId' });
        db.createObjectStore('dids', { keyPath: 'launcherId' });
        // ... índices secundarios
      },
    });
    return new IdbStorage(db);
  }

  async getCoin(coinId: string) {
    const row = await this.db.get('coins', coinId);
    return row?.data ?? null;
  }
  // ...
}
```

### 6.3 Build commands

```bash
# Desde ozone-extension/
pnpm wasm:build
# = cd vendor/sage-web && wasm-pack build crates/sage-wasm \
#     --target web \
#     --out-dir ../../../packages/wallet-wasm \
#     --features coinset-sync,wasm

# Optimización (reduce ~30-40% el tamaño)
pnpm wasm:opt
# = wasm-opt -Oz -o packages/wallet-wasm/sage_wasm_bg.wasm \
#     packages/wallet-wasm/sage_wasm_bg.wasm
```

**Estimación de bundle:** 4-8 MB sin opt, 2-4 MB con `wasm-opt -Oz`. Demasiado para popup load tradicional; estrategias:
- Lazy load: solo cargar WASM cuando se desbloquea la wallet (no en el primer render del popup)
- Streaming compile via `WebAssembly.compileStreaming`
- Pre-compile cache en `chrome.storage.session`

---

## 7. Service Worker MV3 — Gestión del ciclo de vida

**Problema:** SW MV3 muere tras ~30s de inactividad. La wallet desbloqueada y el WASM module se pierden.

**Solución:**

1. **`chrome.storage.session`** para la `derived_key` (encriptada con session ephemeral key):
   - Sobrevive sleep del SW pero se borra al cerrar Chrome
   - Re-derive on SW wakeup sin pedir password

2. **`chrome.alarms`** para keep-alive de sync:
   ```ts
   chrome.alarms.create('sync', { periodInMinutes: 0.5 });  // 30s
   chrome.alarms.create('keepalive', { periodInMinutes: 0.25 });  // 15s, evita muerte
   ```

3. **Estado en `chrome.storage.local`** (persistido entre lifecycle):
   - Wallet metadata (fingerprint, name, derived ph index)
   - Settings (network, rpc provider URLs)
   - Encrypted seed (cifrada con clave derivada de password)

4. **Re-init pattern:**
   ```ts
   // background.ts
   let sageInstance: Sage | null = null;

   async function ensureSage(): Promise<Sage> {
     if (sageInstance) return sageInstance;
     const sessionKey = await chrome.storage.session.get('derivedKey');
     if (!sessionKey) throw new Error('wallet locked, need unlock');
     const wasm = await import('@ozone/wallet-wasm');
     await wasm.default();  // initialize wasm
     const storage = await IdbStorage.open(sessionKey.walletId);
     sageInstance = new wasm.Sage(storage);
     return sageInstance;
   }
   ```

5. **`offscreen` document** (opcional, para mantener WASM vivo):
   - Si latencia de re-init es problemática, crear un offscreen document (Chrome 109+) que vive más tiempo que el SW
   - Tradeoff: añade complejidad de message-passing extra

---

## 8. UI / UX — Minimalista

### 8.1 Diseño de pantallas (popup, 360x600px)

```
┌─────────────────────────────────────┐
│ ┌─────────────────────────────────┐ │  ← Header
│ │ Ozone        [acc▼] [⚙]        │ │
│ └─────────────────────────────────┘ │
│                                     │
│         ╭───────────────╮           │
│         │  12.5432 XCH  │           │  ← Balance principal
│         │   ≈ $XX.YY    │           │
│         ╰───────────────╯           │
│                                     │
│  [ ↑ Send ]  [ ↓ Receive ]          │  ← Actions
│                                     │
│  ── Assets ──                       │
│  USDS       1,234.56                │
│  TIBET LP     0.0042                │
│                                     │
│  ── Recent activity ──              │
│  ↓ Received 0.5 XCH      2m ago     │
│  ↑ Sent 100 USDS         1h ago     │
│                                     │
│ ┌─────────────────────────────────┐ │  ← Tab bar
│ │  💰   🖼️    📜    ⚙        │ │
│ │ Home  NFTs  Offers Settings    │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Pantallas:**
- **Lock**: password input + biometric (si disponible vía `chrome.identity`)
- **Onboarding**: create / import seed (mnemonic input + paste detection)
- **Home**: balance principal + asset list + recent activity
- **Send**: address input (bech32 validation) + amount + asset selector + fee
- **Receive**: QR + bech32 address + index navigator (next/prev derivation)
- **NFTs**: grid de NFTs, click para detalle (metadata, royalty, owner)
- **Offers**: list of pending offers + take offer paste + create offer wizard
- **Activity**: tx history con filtros
- **Settings**: network, rpc provider, change password, export seed (auth), about
- **Approve.html**: ventana popup separada para aprobar conexiones / firmas

### 8.2 Approval UI (CRITICAL para seguridad)

Cuando un dApp llama `signCoinSpends`, debemos decodificar el `CoinSpend[]` y mostrar:

```
┌─────────────────────────────────────┐
│  Sign request from                  │
│  dexie.space                        │
│                                     │
│  ── Summary ──                      │
│  ↑ You send:                        │
│    • 1.5 XCH                        │
│    • 100 USDS                       │
│  ↓ You receive:                     │
│    • NFT: "CryptoKitty #1234"       │
│                                     │
│  Fee: 0.0001 XCH                    │
│                                     │
│  ── Details ──                      │
│  Coin spends: 3                     │
│  Signatures needed: 2 AGG_SIG_ME    │
│                                     │
│  ⚠ AGG_SIG_UNSAFE present (read on) │
│                                     │
│  [ Reject ]      [ Approve ]        │
└─────────────────────────────────────┘
```

**Decoding logic** (vive en `packages/extension/src/lib/decoder.ts`):
1. Para cada `CoinSpend`, ejecutar puzzle+solution → conditions list
2. Sumar `CREATE_COIN` por destinatario (puzzle_hash + amount + memos)
3. Identificar si el inner puzzle es CAT/NFT/DID (matching mod_hashes conocidos)
4. Restar own coins (los del wallet en el coin_spends) → "envío"
5. Sumar destinations no-own → "destino"
6. Si hay `AGG_SIG_UNSAFE`, mostrar warning destacado
7. Si decoding falla, mostrar JSON raw + warning "could not decode"

Esto es **donde Goby vs nuestra extensión se diferencia en valor** — un buen decoder es lo que evita phishing.

---

## 9. Plan de fases y estimación

| Fase | Tareas | Estimado | Bloqueante de |
|------|--------|----------|---------------|
| **0. WASM validation** | Validar que `chia-wallet-sdk` compile a wasm32. Si falla, fork. | 1-3 días | Todo |
| **1. Sage fork setup** | Crear `fork/sage-web` con remotes, branch `web/coinset-sync` | 1 día | Fase 2+ |
| **2. SyncBackend trait + Coinset impl** | Parches 1-3 de sage. Tests nativos. | 5-7 días | Fase 3, 4 |
| **3. Storage abstraction** | Parche 4. IndexedDB impl en TS. | 3-4 días | Fase 5 |
| **4. WASM build + bindings** | Parche 5. wasm-pack toolchain. | 4-6 días | Fase 6+ |
| **5. ozone-extension scaffold** | WXT init, workspace, SW boilerplate | 2 días | Fase 6+ |
| **6. UI básica (XCH only)** | Lock, onboarding, home, send, receive | 5-7 días | Fase 8 |
| **7. Goby provider** | inpage, content bridge, RPC router, approval UI | 4-5 días | - |
| **8. CAT support** | Asset list, send CAT, watch asset, balance | 3-4 días | - |
| **9. NFT support** | Grid, detail, transfer, mint flow | 4-5 días | - |
| **10. Offers** | Make offer wizard, take offer paste, cancel | 4-5 días | - |
| **11. DID support** | Create, update metadata, recovery | 3-4 días | - |
| **12. Testing vs dApps reales** | Dexie, MintGarden, Spacescan integration tests | 3-5 días | Release |
| **13. Polish + security review** | Decoder UI, error handling, edge cases | 5-7 días | Release |

**Total estimado:** ~7-10 semanas full-time. Más realista con cambios de contexto: 10-14 semanas.

**Críticos para empezar:**
1. Fase 0 (WASM validation) — go/no-go
2. Fase 1-2 en paralelo con Fase 5 (UI scaffold puede empezar antes de tener WASM real, con mocks)

---

## 10. Riesgos y mitigaciones

| Riesgo | Severidad | Mitigación |
|--------|-----------|------------|
| `chia-wallet-sdk` no compila a WASM | **Alto** | Fork también; patches en `vendor/chia-wallet-sdk-web`. Detectar en Fase 0. |
| Bundle WASM > 5MB | Medio | `wasm-opt -Oz`, code-split por wallet operation, streaming compile |
| Service worker muerte → re-init lento | Medio | Offscreen document, session-cached derived key |
| `coinset.org` downtime | Medio | Multi-provider fallback (FireAcademy), self-host URL option |
| `coinset.org` corrupto/malicious | Alto | UI muestra "trusted indexer" + cross-check con segundo provider en operaciones sensibles |
| Reorgs > 32 blocks | Bajo (rare) | Re-sync forzado si peak decrece |
| Goby spec changes (no es estándar formal) | Bajo | Testing continuo vs dApps reales |
| Chrome Web Store approval | Medio | Manifest V3 desde día 1, no `eval`, no remote code (WASM bundled está OK) |
| Key material en service worker memory | Alto (security) | Session-encrypted, never `chrome.storage.local` plaintext, auto-lock timer |
| NFT/DID puzzle parsing edge cases | Medio | Reusar `chia-wallet-sdk` parsing (battle-tested), no reimplementar |
| Performance del sync (muchas derivaciones) | Medio | Batch endpoints, paralelizar con throttle, IndexedDB indexing |

---

## 11. Estado de investigación

### 11.1 Completadas

- ✅ **Arquitectura de sage actual** — `crates/sage-wallet/src/sync_manager.rs` confirma peer-sync acoplado, refactor con trait es claro
- ✅ **API de coinset.org** — todos los endpoints verificados live, CORS abierto, sin auth, schemas listados
- ✅ **Goby protocol spec** — CHIP-0002 + ext, Sage WalletConnect commands sirven de referencia 1:1
- ✅ **Diferencias P2P vs REST** — gaps identificados, todos manejables con polling + cross-check

### 11.2 En progreso (agentes background)

- ⏳ **`chia-wallet-sdk` WASM viability** — agente `a1682fbf07963b67e`
  - Verifica si compila a `wasm32-unknown-unknown`
  - Si no, lista patches necesarios
  - Output esperado en `/private/tmp/claude-501/.../tasks/a1682fbf07963b67e.output`

- ⏳ **chia-blockchain wallet protocol deep-dive** — agente `aa92e16e0fa0c7bb0`
  - State machine de sync upstream
  - Hint mechanism details
  - NFT/DID puzzle detection
  - Output esperado en `/private/tmp/claude-501/.../tasks/aa92e16e0fa0c7bb0.output`

**Continuación en móvil:** cuando estos agentes completen, sus hallazgos se anexan a este documento en sección 13.

### 11.3 Pending de investigar (post-WASM-validation)

- Si `chia-wallet-sdk` no compila: ¿qué exactamente hay que parchear? (tokio features, rustls native vs ring, etc.)
- ¿`sqlx` puede usarse con backend custom (no sqlite) en WASM? — probablemente no, mejor abstraer
- Bundle size real medido tras primer wasm-pack build
- Best-practices de Chrome Web Store review para extensiones cripto (KYC, age gating?)

---

## 12. Próximos pasos inmediatos

Cuando vuelvas a esto:

1. **Ejecutar Fase 0** — probar `cargo check --target wasm32-unknown-unknown` en `chia-wallet-sdk` + reportar.
2. **Si Fase 0 pasa:** crear `fork/sage-web` (clone xch-dev/sage, set remotes), crear branch `web/coinset-sync`.
3. **Crear `ozone-extension`** con WXT scaffold + workspace.
4. **Empezar Parche 1** (`SyncBackend` trait) en el fork.

```bash
# Comandos exactos para empezar:
mkdir -p ~/Projects/Ozone/fork
cd ~/Projects/Ozone/fork
git clone https://github.com/xch-dev/sage.git sage-web
cd sage-web
git remote add upstream https://github.com/xch-dev/sage.git
git remote set-url --push upstream DISABLED
git checkout -b web/coinset-sync

# Verificación WASM:
cd crates/sage-wallet
cargo check --target wasm32-unknown-unknown --no-default-features 2>&1 | head -100

# Si OK, scaffold extension:
cd ~/Projects/Ozone
pnpm create wxt@latest ozone-extension -- --template react-ts
cd ozone-extension
pnpm install
git init && git add . && git commit -m "chore: WXT scaffold"
```

---

## 13. Anexos (a completar cuando agentes terminen)

### 13.1 chia-wallet-sdk WASM analysis
*(pendiente — agente background)*

### 13.2 chia-blockchain wallet protocol deep dive
*(pendiente — agente background)*

---

## 14. Referencias

- [CHIP-0002 — Chia dApp Protocol](https://github.com/Chia-Network/chips/blob/main/CHIPs/chip-0002.md)
- [Goby docs](https://docs.goby.app/)
- [Sage repo (xch-dev)](https://github.com/xch-dev/sage)
- [coinset.org](https://api.coinset.org/)
- [FireAcademy.io Leaflet](https://docs.fireacademy.io/)
- [chia-blockchain](https://github.com/Chia-Network/chia-blockchain)
- [chia-wallet-sdk](https://github.com/xch-dev/chia-wallet-sdk)
- [Hoogii (CHIP-0002 ref impl)](https://github.com/hashgreen/hoogii-wallet)
- [WXT framework](https://wxt.dev/)
- Internal: `vendor/sage/src/walletconnect/commands.ts` — Zod schemas de cada chip0002_* / chia_*

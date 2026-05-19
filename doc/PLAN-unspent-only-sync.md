# Plan: opción `sync_spent_coins` (sync rápido unspent-only)

> Estado: **pendiente de ejecutar**. Decisiones tomadas:
> - Enfoque: **setting configurable**, replicando el patrón completo de `delta_sync`.
> - Default: **`sync_spent_coins = true`** (comportamiento actual, historial completo). El modo rápido es **opt-in**.

## Objetivo

Hoy la sincronización inicial es lenta porque
[`wallet_sync.rs:183`](../vendor/sage/crates/sage-wallet/src/sync_manager/wallet_sync.rs#L183)
pide al peer **todas** las monedas (gastadas + no gastadas) de los puzzle hashes del wallet:

```rust
CoinStateFilters::new(true, true, true, 0)   // include_spent = true
```

Con `include_spent = false` el peer devuelve solo el UTXO actual → sync mucho más
rápido y balance XCH/CAT correcto. Coste conocido (aceptado): sin historial de
transacciones, sin assets históricos que ya no se poseen, y la conciliación de
mempool/tx salientes solo opera hacia adelante (delta sync), no replayando historial.
Los CAT/NFT que sí se poseen siguen resolviéndose (la cola de puzzles trae el padre
on-demand).

No existe forma de hacerlo sólo por configuración/endpoint sin tocar el fork: el
filtro es un literal hardcodeado en un único sitio y `SyncOptions` no lo expone.
`vendor/sage` es el fork propio (`MarvinQuevedo/sage`, rama
`flutter-binding/v0.12.10`), así que se parchea ahí.

## Patrón de referencia

`delta_sync` ya está cableado de punta a punta exactamente con la forma que
necesitamos. **Replicar ese patrón** añadiendo `sync_spent_coins` en paralelo en
cada capa.

---

## Cambios en el submódulo `vendor/sage`

### 1. `crates/sage-config/src/wallet.rs`

- `WalletDefaults` (≈L13): añadir campo
  ```rust
  pub sync_spent_coins: bool,
  ```
- `impl Default for WalletDefaults` (≈L19): `sync_spent_coins: true,`
- `struct Wallet` (≈L29, junto a `delta_sync: Option<bool>`, **sin** `skip_serializing_if`):
  ```rust
  pub sync_spent_coins: Option<bool>,
  ```
- `impl Wallet` (≈L37): accesor en paralelo a `delta_sync`:
  ```rust
  pub fn sync_spent_coins(&self, defaults: &WalletDefaults) -> bool {
      self.sync_spent_coins.unwrap_or(defaults.sync_spent_coins)
  }
  ```
- `impl Default for Wallet` (≈L48): `sync_spent_coins: None,`
- `#[cfg(test)] mod tests` (≈L62-70): añadir `sync_spent_coins: None,` a los literales `Wallet`.
- Snapshots `expect_test` (≈L92, L102, L108): se actualizan con `UPDATE_EXPECT=1` (ver Verificación).

### 2. `crates/sage-config/src/old.rs`

- Literal `Wallet` (≈L155, donde aparece `delta_sync: None`): añadir `sync_spent_coins: None,`.

### 3. `crates/sage-api/src/requests/settings.rs`

Replicar `SetDeltaSync` / `SetDeltaSyncOverride` (≈L200-228), con los mismos
`#[cfg_attr(feature = "openapi", crate::openapi_attr(tag = "Network Settings", ... response_type = "EmptyResponse"))]`
y derives `tauri`/`openapi`:

```rust
pub struct SetSyncSpentCoins {
    /// Whether to sync spent coins (full history). false = fast, unspent-only.
    pub sync_spent_coins: bool,
}

pub struct SetSyncSpentCoinsOverride {
    pub fingerprint: u32,
    pub sync_spent_coins: Option<bool>,
}
```

Y los alias de respuesta (junto a L262-263):

```rust
pub type SetSyncSpentCoinsResponse = EmptyResponse;
pub type SetSyncSpentCoinsOverrideResponse = EmptyResponse;
```

### 4. `crates/sage-api/endpoints.json`

Junto a `set_delta_sync` (≈L90-91), añadir (valor `false` = fn síncrona, sin `.await`):

```json
"set_sync_spent_coins": false,
"set_sync_spent_coins_override": false,
```

> El binding (`impl_endpoints_tauri!` en [sage_client.rs](../rust/src/api/sage_client.rs))
> lee este JSON en tiempo de compilación; el endpoint queda expuesto automáticamente
> vía `client.call("set_sync_spent_coins", ...)` sin codegen.

### 5. `crates/sage/src/endpoints/settings.rs`

- Añadir los tipos nuevos al bloque `use` (≈L7-8).
- Replicar `set_delta_sync` / `set_delta_sync_override` (≈L139-160):

```rust
pub fn set_sync_spent_coins(&mut self, req: SetSyncSpentCoins)
    -> Result<SetSyncSpentCoinsResponse> {
    self.wallet_config.defaults.sync_spent_coins = req.sync_spent_coins;
    self.save_config()?;
    Ok(SetSyncSpentCoinsResponse {})
}

pub fn set_sync_spent_coins_override(&mut self, req: SetSyncSpentCoinsOverride)
    -> Result<SetSyncSpentCoinsOverrideResponse> {
    let Some(wallet_config) = self.wallet_config.wallets
        .iter_mut().find(|w| w.fingerprint == req.fingerprint)
    else { return Err(Error::UnknownFingerprint); };
    wallet_config.sync_spent_coins = req.sync_spent_coins;
    self.save_config()?;
    Ok(SetSyncSpentCoinsOverrideResponse {})
}
```

> Igual que `set_delta_sync`, **solo escribe config**: surte efecto en el próximo
> `switch_wallet` / reinicio (no fuerza re-sync en caliente). Documentar este matiz.

### 6. `crates/sage/src/sage.rs` — `setup_sync_manager` (≈L230-256)

En el literal `SyncOptions { ... }`, añadir el campo leyendo config como `delta_sync`:

```rust
sync_spent_coins: self
    .wallet_config()
    .cloned()
    .unwrap_or_default()
    .sync_spent_coins(&self.wallet_config.defaults),
```

### 7. `crates/sage-wallet/src/sync_manager/options.rs`

`struct SyncOptions`: añadir `pub sync_spent_coins: bool,`.

### 8. `crates/sage-wallet/src/sync_manager.rs`

- Spawn de `sync_wallet(...)` (≈L375-382): pasar `self.options.sync_spent_coins` como
  nuevo argumento.
- Llamada a `add_new_subscriptions(...)` (en el handler de `SyncCommand::SubscribePuzzles`):
  pasar también `self.options.sync_spent_coins` para que las nuevas suscripciones de
  puzzles usen el mismo filtro.

### 9. `crates/sage-wallet/src/sync_manager/wallet_sync.rs`

- `sync_wallet(...)`: añadir parámetro `sync_spent_coins: bool`.
- `add_new_subscriptions(...)`: añadir parámetro `sync_spent_coins: bool`.
- `sync_puzzle_hashes(...)`: añadir parámetro `sync_spent_coins: bool` y propagarlo
  a **todas** sus invocaciones internas (≈L51, L81, L336) y al bucle de derivaciones.
- **L183**: el cambio efectivo:
  ```rust
  CoinStateFilters::new(sync_spent_coins, true, true, 0)
  ```
  (`sync_coin_ids` usa `subscribe_coins`, sin filtro → no requiere cambios funcionales.)

---

## Verificación

```bash
# 1. El fork compila
cd vendor/sage && SQLX_OFFLINE=true cargo check -p sage

# 2. Actualizar snapshots expect_test de sage-config y revisar diff
cd vendor/sage && UPDATE_EXPECT=1 cargo test -p sage-config
git -C vendor/sage diff -- crates/sage-config   # revisar que solo añade sync_spent_coins

# 3. Regenerar API tipada Dart + doc/API.md desde el OpenAPI del fork
tool/generate_api.sh

# 4. El binding compila
cd rust && cargo check

# 5. Smoke test desde Dart (example/lib/main.dart o test):
#    - Sin llamar nada  -> sync histórico completo (default, sin regresión).
#    - client.call("set_sync_spent_coins", '{"sync_spent_coins": false}')
#      luego login + switch_wallet -> sync notablemente más rápido,
#      balance XCH/CAT correcto, historial de tx vacío/parcial (esperado).
```

## Commit / submódulo

1. Commitear los cambios **dentro de `vendor/sage`** y push a la rama del fork
   `flutter-binding/v0.12.10`.
2. En el repo padre: `git add vendor/sage` (bump del puntero) + los regenerados
   `lib/src/sage_api.g.dart`, `doc/API.md` y este plan.

## Rollback

Default `true` ⇒ aunque se publique, el comportamiento no cambia salvo que la app
haga opt-in. Revertir = revertir el commit del padre + puntero del submódulo.

## Riesgo / notas

- Modo rápido (`false`): sin historial de tx, sin assets históricos no poseídos,
  conciliación mempool solo hacia adelante. CAT/NFT poseídos siguen resolviéndose
  vía cola de puzzles (padre on-demand).
- Cambio aditivo y reversible; potencialmente upstreamable (mismo patrón que
  `delta_sync`).
- El setting surte efecto en el próximo `switch_wallet`/reinicio, no en caliente.

import { useEffect, useState } from "react";
import { callEngine, getSyncState, setActiveWallet } from "../../src/popup/engine-client";
import type { SyncState } from "../../src/popup/engine-client";
import {
  getDerivationState,
  setActiveIndex,
  setLabel,
} from "../../src/popup/derivation-store";
import { Qr } from "../../src/popup/qr";
import {
  getActiveFingerprint,
  listWallets,
  removeWallet,
  saveWallet,
  setActiveFingerprint,
  type StoredWallet,
} from "../../src/popup/wallet-store";

type View =
  | { kind: "loading" }
  | { kind: "onboarding" }
  | { kind: "locked"; wallet: StoredWallet }
  | { kind: "home"; wallet: StoredWallet };

export function App() {
  const [view, setView] = useState<View>({ kind: "loading" });

  useEffect(() => {
    void (async () => {
      const wallets = await listWallets();
      if (wallets.length === 0) {
        setView({ kind: "onboarding" });
        return;
      }
      const activeFp = await getActiveFingerprint();
      const active = activeFp ? wallets.find((w) => w.fingerprint === activeFp) : wallets[0];
      const target = active ?? wallets[0]!;

      // If a fingerprint is in chrome.storage.session AND the engine still has
      // the SK cached, jump straight to home. Otherwise lock.
      if (activeFp) {
        try {
          const res = await callEngine<{ unlocked: boolean }>("is_unlocked", {
            fingerprint: target.fingerprint,
          });
          if (res.unlocked) {
            await setActiveWallet(target.fingerprint.toString());
            setView({ kind: "home", wallet: target });
            return;
          }
        } catch {
          // ignore — fall through to lock
        }
      }
      setView({ kind: "locked", wallet: target });
    })();
  }, []);

  return (
    <div className="ozone-popup">
      <header className="ozone-header">
        <span className="ozone-logo">Ozone</span>
      </header>
      <main>
        {view.kind === "loading" && <LoadingScreen />}
        {view.kind === "onboarding" && (
          <OnboardingScreen
            onDone={async (w) => {
              await setActiveFingerprint(w.fingerprint);
              await setActiveWallet(w.fingerprint.toString());
              setView({ kind: "home", wallet: w });
            }}
          />
        )}
        {view.kind === "locked" && (
          <LockScreen
            wallet={view.wallet}
            onUnlocked={async (w) => {
              await setActiveFingerprint(w.fingerprint);
              await setActiveWallet(w.fingerprint.toString());
              setView({ kind: "home", wallet: w });
            }}
          />
        )}
        {view.kind === "home" && (
          <HomeScreen
            wallet={view.wallet}
            onLock={async () => {
              try {
                await callEngine("lock_keychain", { fingerprint: view.wallet.fingerprint });
              } catch {
                // best-effort
              }
              await setActiveFingerprint(null);
              await setActiveWallet(null);
              setView({ kind: "locked", wallet: view.wallet });
            }}
          />
        )}
      </main>
    </div>
  );
}

function LoadingScreen() {
  return (
    <section className="screen">
      <p className="muted">Loading…</p>
    </section>
  );
}

function OnboardingScreen({ onDone }: { onDone: (w: StoredWallet) => void | Promise<void> }) {
  const [mode, setMode] = useState<"choose" | "create" | "import">("choose");
  const [mnemonic, setMnemonic] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const generate = async () => {
    setError(null);
    try {
      const res = await callEngine<{ mnemonic: string }>("generate_mnemonic", { words: 24 });
      setMnemonic(res.mnemonic);
      setMode("create");
    } catch (err) {
      setError((err as Error).message);
    }
  };

  const finish = async () => {
    if (!password.trim()) {
      setError("Set a password");
      return;
    }
    setBusy(true);
    setError(null);
    try {
      const importRes = await callEngine<{
        fingerprint: number;
        keychain_blob: string;
      }>("import_mnemonic", {
        mnemonic: mnemonic.trim(),
        password,
        testnet: false,
      });
      const wallet: StoredWallet = {
        fingerprint: importRes.fingerprint,
        keychainBlob: importRes.keychain_blob,
        label: `Wallet ${importRes.fingerprint}`,
        createdAt: Date.now(),
      };
      await saveWallet(wallet);
      // setActiveWallet (inside onDone) will recreate the engine bound to the
      // wallet's IDB; unlock_keychain AFTER that so the SK lives in the right
      // engine instance.
      await onDone(wallet);
      await callEngine("unlock_keychain", {
        keychain_blob: importRes.keychain_blob,
        fingerprint: importRes.fingerprint,
        password,
      });
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  };

  if (mode === "choose") {
    return (
      <section className="screen">
        <h1>Welcome to Ozone</h1>
        <p className="muted">A Chia wallet for your browser. Choose how to get started.</p>
        {error && <p className="error">{error}</p>}
        <button onClick={generate}>Create new wallet</button>
        <button className="secondary" onClick={() => setMode("import")}>
          Import existing mnemonic
        </button>
      </section>
    );
  }

  const words = mnemonic.trim().split(/\s+/).filter(Boolean);

  return (
    <section className="screen">
      <h1>{mode === "create" ? "Save your seed phrase" : "Import mnemonic"}</h1>
      {mode === "create" && (
        <p className="muted">
          Write these 24 words down somewhere safe. They're the only way to recover your wallet.
        </p>
      )}
      {mode === "create" && words.length === 24 ? (
        <div className="seed-grid">
          {words.map((w, i) => (
            <span className="seed-pill" key={i}>
              <span className="seed-pill-index">{i + 1}</span>
              <span className="seed-pill-word">{w}</span>
            </span>
          ))}
        </div>
      ) : (
        <textarea
          value={mnemonic}
          onChange={(e) => setMnemonic(e.target.value)}
          rows={4}
          spellCheck={false}
          placeholder="12 or 24 words, space-separated"
        />
      )}
      <label className="field">
        <span>Password</span>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Used to encrypt the seed on this device"
        />
      </label>
      {error && <p className="error">{error}</p>}
      <div className="row">
        <button className="secondary" onClick={() => setMode("choose")} disabled={busy}>
          Back
        </button>
        <button onClick={finish} disabled={busy || !mnemonic.trim() || !password.trim()}>
          {busy ? "Saving…" : "Continue"}
        </button>
      </div>
    </section>
  );
}

function LockScreen({
  wallet,
  onUnlocked,
}: {
  wallet: StoredWallet;
  onUnlocked: (w: StoredWallet) => void | Promise<void>;
}) {
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const unlock = async () => {
    setBusy(true);
    setError(null);
    try {
      await callEngine<{ fingerprint: number; mnemonic: string }>("unlock_keychain", {
        keychain_blob: wallet.keychainBlob,
        fingerprint: wallet.fingerprint,
        password,
      });
      await onUnlocked(wallet);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  };

  return (
    <section className="screen">
      <h1>Unlock</h1>
      <p className="muted">{wallet.label}</p>
      <label className="field">
        <span>Password</span>
        <input
          type="password"
          autoFocus
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && !busy && password) void unlock();
          }}
        />
      </label>
      {error && <p className="error">{error}</p>}
      <button onClick={unlock} disabled={busy || !password}>
        {busy ? "Unlocking…" : "Unlock"}
      </button>
    </section>
  );
}

interface BalanceInfo {
  total_unspent_mojos: string;
  total_unspent_xch: string;
  unspent_coin_count: number;
  addresses: Array<{
    index: number;
    puzzle_hash: string;
    address: string;
    unspent_mojos: string;
    unspent_count: number;
  }>;
}

function HomeScreen({
  wallet,
  onLock,
}: {
  wallet: StoredWallet;
  onLock: () => void | Promise<void>;
}) {
  const [tab, setTab] = useState<"home" | "send" | "receive" | "dev" | "settings">("home");
  const [sync, setSync] = useState<SyncState | null>(null);
  const [balance, setBalance] = useState<BalanceInfo | null>(null);
  const [balanceError, setBalanceError] = useState<string | null>(null);
  const [balanceLoading, setBalanceLoading] = useState(false);

  const refreshSync = async () => {
    try {
      const cached = await getSyncState();
      setSync(cached);
    } catch {
      // ignore — best-effort
    }
  };

  const refreshBalance = async () => {
    setBalanceLoading(true);
    try {
      const res = await callEngine<BalanceInfo>("get_address_balance", {
        fingerprint: wallet.fingerprint,
        start: 0,
        count: 50,
        testnet: false,
      });
      setBalance(res);
      setBalanceError(null);
    } catch (err) {
      setBalanceError((err as Error).message);
    } finally {
      setBalanceLoading(false);
    }
  };

  useEffect(() => {
    void refreshSync();
    void refreshBalance();
    const id = setInterval(() => {
      void refreshSync();
    }, 5_000);
    const balanceTimer = setInterval(() => {
      void refreshBalance();
    }, 30_000);
    return () => {
      clearInterval(id);
      clearInterval(balanceTimer);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [wallet.fingerprint]);

  return (
    <section className="screen">
      <div className="wallet-bar">
        <div>
          <h1 className="balance">
            {balance ? `${balance.total_unspent_xch} XCH` : balanceLoading ? "…" : "0.0000 XCH"}
          </h1>
          <p className="muted">
            {wallet.label} · fp {wallet.fingerprint}
            {balance && balance.unspent_coin_count > 0 && (
              <> · {balance.unspent_coin_count} coins</>
            )}
          </p>
        </div>
        <div className="sync-badge">
          {sync && !sync.error ? (
            <>
              <span className={sync.synced ? "ok" : "warn"}>
                {sync.synced ? "synced" : "syncing"}
              </span>
              <code>#{sync.peak_height.toLocaleString()}</code>
              <span className="muted small">mempool {sync.mempool_size}</span>
            </>
          ) : sync?.error ? (
            <span className="error small">offline</span>
          ) : (
            <span className="muted small">connecting…</span>
          )}
        </div>
      </div>

      <nav className="tabs">
        <button
          className={tab === "home" ? "tab active" : "tab"}
          onClick={() => setTab("home")}
        >
          Home
        </button>
        <button
          className={tab === "send" ? "tab active" : "tab"}
          onClick={() => setTab("send")}
        >
          Send
        </button>
        <button
          className={tab === "receive" ? "tab active" : "tab"}
          onClick={() => setTab("receive")}
        >
          Receive
        </button>
        <button
          className={tab === "settings" ? "tab active" : "tab"}
          onClick={() => setTab("settings")}
        >
          Settings
        </button>
      </nav>

      {tab === "home" && (
        <HomeTab balance={balance} balanceError={balanceError} onRefresh={() => void refreshBalance()} />
      )}
      {tab === "send" && <SendTab wallet={wallet} balance={balance} />}
      {tab === "receive" && <ReceiveTab wallet={wallet} />}
      {tab === "dev" && <DevTab wallet={wallet} />}
      {tab === "settings" && <SettingsTab wallet={wallet} sync={sync} onLock={onLock} />}

      <button onClick={() => void onLock()} className="lock-btn">
        Lock
      </button>
    </section>
  );
}

function SettingsTab({
  wallet,
  sync,
  onLock,
}: {
  wallet: StoredWallet;
  sync: SyncState | null;
  onLock: () => void | Promise<void>;
}) {
  const [revealing, setRevealing] = useState(false);
  const [revealPwd, setRevealPwd] = useState("");
  const [revealedMnemonic, setRevealedMnemonic] = useState<string | null>(null);
  const [revealError, setRevealError] = useState<string | null>(null);
  const [confirmingReset, setConfirmingReset] = useState(false);
  const [copiedFingerprint, setCopiedFingerprint] = useState(false);

  const revealSeed = async () => {
    setRevealError(null);
    try {
      const res = await callEngine<{ mnemonic: string }>("unlock_keychain", {
        keychain_blob: wallet.keychainBlob,
        fingerprint: wallet.fingerprint,
        password: revealPwd,
      });
      setRevealedMnemonic(res.mnemonic);
    } catch (err) {
      setRevealError((err as Error).message);
    }
  };

  const copyFp = async () => {
    await navigator.clipboard.writeText(wallet.fingerprint.toString());
    setCopiedFingerprint(true);
    setTimeout(() => setCopiedFingerprint(false), 1500);
  };

  const resetWallet = async () => {
    await removeWallet(wallet.fingerprint);
    await callEngine("lock_keychain", { fingerprint: wallet.fingerprint });
    await onLock();
  };

  return (
    <div className="tab-body">
      <h3>Wallet</h3>
      <div className="result">
        <div>
          <span className="muted">label</span>
          <code>{wallet.label}</code>
        </div>
        <div onClick={() => void copyFp()} style={{ cursor: "pointer" }}>
          <span className="muted">fingerprint {copiedFingerprint && "· copied"}</span>
          <code>{wallet.fingerprint}</code>
        </div>
        <div>
          <span className="muted">created</span>
          <code>{new Date(wallet.createdAt).toLocaleString()}</code>
        </div>
      </div>

      <h3>Network</h3>
      <div className="result">
        <div>
          <span className="muted">endpoint</span>
          <code>api.coinset.org · mainnet</code>
        </div>
        {sync && (
          <div>
            <span className="muted">peak height</span>
            <code>#{sync.peak_height.toLocaleString()}</code>
          </div>
        )}
      </div>

      <h3>Recovery phrase</h3>
      {!revealing && !revealedMnemonic && (
        <button className="secondary" onClick={() => setRevealing(true)}>
          Show recovery phrase
        </button>
      )}
      {revealing && !revealedMnemonic && (
        <>
          <p className="muted">Enter your password to view the 24-word seed.</p>
          <input
            type="password"
            placeholder="Password"
            value={revealPwd}
            onChange={(e) => setRevealPwd(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && revealPwd) void revealSeed();
            }}
          />
          {revealError && <p className="error">{revealError}</p>}
          <div className="row">
            <button
              className="secondary"
              onClick={() => {
                setRevealing(false);
                setRevealPwd("");
                setRevealError(null);
              }}
            >
              Cancel
            </button>
            <button onClick={() => void revealSeed()} disabled={!revealPwd}>
              Reveal
            </button>
          </div>
        </>
      )}
      {revealedMnemonic && (
        <>
          <div className="seed-grid">
            {revealedMnemonic.split(/\s+/).map((w, i) => (
              <span className="seed-pill" key={i}>
                <span className="seed-pill-index">{i + 1}</span>
                <span className="seed-pill-word">{w}</span>
              </span>
            ))}
          </div>
          <button
            className="secondary"
            onClick={() => {
              setRevealedMnemonic(null);
              setRevealPwd("");
              setRevealing(false);
            }}
          >
            Hide
          </button>
        </>
      )}

      <h3>Danger zone</h3>
      {!confirmingReset && (
        <button className="danger" onClick={() => setConfirmingReset(true)}>
          Remove this wallet
        </button>
      )}
      {confirmingReset && (
        <>
          <p className="muted">
            This deletes the encrypted seed from this browser. Make sure you have your
            recovery phrase before continuing.
          </p>
          <div className="row">
            <button className="secondary" onClick={() => setConfirmingReset(false)}>
              Cancel
            </button>
            <button className="danger" onClick={() => void resetWallet()}>
              Remove
            </button>
          </div>
        </>
      )}
    </div>
  );
}

function HomeTab({
  balance,
  balanceError,
  onRefresh,
}: {
  balance: BalanceInfo | null;
  balanceError: string | null;
  onRefresh: () => void;
}) {
  const fundedAddresses = balance?.addresses.filter((a) => a.unspent_count > 0) ?? [];

  return (
    <div className="tab-body">
      <ul className="status-list">
        <li>
          <span className="muted">XCH</span>
          <span>{balance ? balance.total_unspent_xch : "—"}</span>
        </li>
        <li>
          <span className="muted">Coins</span>
          <span>{balance ? balance.unspent_coin_count : "—"}</span>
        </li>
        <li>
          <span className="muted">CATs</span>
          <span className="muted">—</span>
        </li>
        <li>
          <span className="muted">NFTs</span>
          <span className="muted">—</span>
        </li>
      </ul>

      {fundedAddresses.length > 0 && (
        <>
          <h3>Holdings</h3>
          <ul className="address-list">
            {fundedAddresses.map((a) => (
              <li key={a.index}>
                <span className="address-index">#{a.index}</span>
                <code>{a.address}</code>
                <span className="small ok">
                  {mojosToXch(a.unspent_mojos)}
                </span>
              </li>
            ))}
          </ul>
        </>
      )}

      {balanceError && <p className="error">{balanceError}</p>}
      <button className="secondary" onClick={onRefresh}>
        Refresh balance
      </button>
      <p className="muted small">
        Balances are read live from coinset.org across your first 50 derived addresses.
      </p>
    </div>
  );
}

function mojosToXch(mojos: string): string {
  // Mojos as decimal string → "X.XXXX" XCH. Simple impl using BigInt.
  try {
    const m = BigInt(mojos);
    const scale = 1_000_000_000_000n;
    const whole = m / scale;
    const frac = m % scale;
    const fracStr = frac.toString().padStart(12, "0").replace(/0+$/, "");
    const display = fracStr.length === 0 ? "0000" : fracStr.padEnd(4, "0");
    return `${whole}.${display}`;
  } catch {
    return mojos;
  }
}

function SendTab({ wallet, balance }: { wallet: StoredWallet; balance: BalanceInfo | null }) {
  const [to, setTo] = useState("");
  const [amount, setAmount] = useState("");
  const [fee, setFee] = useState("0");
  const [addressValid, setAddressValid] = useState<boolean | null>(null);
  const [addressInfo, setAddressInfo] = useState<{ puzzle_hash: string; prefix: string } | null>(
    null,
  );
  const [validating, setValidating] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitNote, setSubmitNote] = useState<string | null>(null);

  useEffect(() => {
    if (!to.trim()) {
      setAddressValid(null);
      setAddressInfo(null);
      return;
    }
    let cancelled = false;
    setValidating(true);
    const t = setTimeout(async () => {
      try {
        const res = await callEngine<{ puzzle_hash: string; prefix: string }>(
          "decode_address",
          { address: to.trim() },
        );
        if (!cancelled) {
          setAddressValid(true);
          setAddressInfo(res);
        }
      } catch {
        if (!cancelled) {
          setAddressValid(false);
          setAddressInfo(null);
        }
      } finally {
        if (!cancelled) setValidating(false);
      }
    }, 300);
    return () => {
      cancelled = true;
      clearTimeout(t);
    };
  }, [to]);

  const amountNum = parseFloat(amount || "0");
  const feeNum = parseFloat(fee || "0");
  const totalNeeded = amountNum + feeNum;
  const haveEnough = balance
    ? BigInt(balance.total_unspent_mojos) >=
      BigInt(Math.round(totalNeeded * 1_000_000_000_000))
    : false;

  const canReview = addressValid && amountNum > 0 && haveEnough;

  const review = () => {
    setSubmitError(null);
    setSubmitNote(
      "Send is wired up to the engine but the on-chain push is still " +
        "behind the storage bridge refactor. Address + amount + fee validated, " +
        "but no SpendBundle is broadcast yet. Coming in the next iteration.",
    );
  };

  return (
    <div className="tab-body">
      <label className="field">
        <span>Recipient address</span>
        <input
          type="text"
          value={to}
          onChange={(e) => setTo(e.target.value)}
          placeholder="xch1..."
          spellCheck={false}
        />
        {validating && <span className="muted small">validating…</span>}
        {addressValid === true && addressInfo && (
          <span className="small ok">✓ valid {addressInfo.prefix} address</span>
        )}
        {addressValid === false && <span className="small error">invalid bech32m</span>}
      </label>

      <label className="field">
        <span>Amount (XCH)</span>
        <input
          type="number"
          step="0.0001"
          min="0"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="0.0"
        />
        {balance && amountNum > 0 && !haveEnough && (
          <span className="small error">
            insufficient: have {balance.total_unspent_xch} XCH
          </span>
        )}
      </label>

      <label className="field">
        <span>Fee (XCH)</span>
        <input
          type="number"
          step="0.0001"
          min="0"
          value={fee}
          onChange={(e) => setFee(e.target.value)}
        />
        <span className="muted small">
          A fee helps your transaction land faster when the mempool is busy.
        </span>
      </label>

      <button disabled={!canReview} onClick={review}>
        Review & send
      </button>

      {submitNote && <p className="muted small">{submitNote}</p>}
      {submitError && <p className="error">{submitError}</p>}

      <p className="muted small">
        Sending {wallet.label}: {balance?.total_unspent_xch ?? "—"} XCH available across{" "}
        {balance?.unspent_coin_count ?? 0} coins.
      </p>
    </div>
  );
}

interface DerivedAddress {
  index: number;
  address: string;
  puzzle_hash: string;
  public_key: string;
}

function ReceiveTab({ wallet }: { wallet: StoredWallet }) {
  const [addresses, setAddresses] = useState<DerivedAddress[]>([]);
  const [active, setActive] = useState<number>(0);
  const [labels, setLabels] = useState<Record<string, string>>({});
  const [editingLabel, setEditingLabel] = useState<string>("");
  const [editing, setEditing] = useState(false);
  const [showAll, setShowAll] = useState(false);
  const [copied, setCopied] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Load persisted state + derive a chunk of addresses
  useEffect(() => {
    let cancelled = false;
    void (async () => {
      const state = await getDerivationState(wallet.fingerprint);
      if (cancelled) return;
      setActive(state.activeIndex);
      setLabels(state.labels);
      try {
        // Derive enough to cover the selected index + reasonable browsing range
        const count = Math.max(20, state.activeIndex + 10);
        const res = await callEngine<{ addresses: DerivedAddress[] }>("derive_addresses", {
          fingerprint: wallet.fingerprint,
          start: 0,
          count,
          testnet: false,
        });
        if (!cancelled) setAddresses(res.addresses);
      } catch (err) {
        if (!cancelled) setError((err as Error).message);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [wallet.fingerprint]);

  const activeAddr = addresses.find((a) => a.index === active) ?? addresses[0];

  const copy = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    } catch {
      // clipboard may be denied
    }
  };

  const nextAddress = async () => {
    const next = (activeAddr?.index ?? -1) + 1;
    // ensure we have it derived
    if (next >= addresses.length) {
      try {
        const res = await callEngine<{ addresses: DerivedAddress[] }>("derive_addresses", {
          fingerprint: wallet.fingerprint,
          start: addresses.length,
          count: 10,
          testnet: false,
        });
        setAddresses([...addresses, ...res.addresses]);
      } catch (err) {
        setError((err as Error).message);
        return;
      }
    }
    setActive(next);
    await setActiveIndex(wallet.fingerprint, next);
  };

  const pickAddress = async (idx: number) => {
    setActive(idx);
    await setActiveIndex(wallet.fingerprint, idx);
    setShowAll(false);
  };

  const startEditLabel = () => {
    setEditingLabel(labels[String(active)] ?? "");
    setEditing(true);
  };

  const saveEditLabel = async () => {
    await setLabel(wallet.fingerprint, active, editingLabel);
    const nextLabels = { ...labels };
    if (editingLabel.trim()) nextLabels[String(active)] = editingLabel.trim();
    else delete nextLabels[String(active)];
    setLabels(nextLabels);
    setEditing(false);
  };

  if (!activeAddr) {
    return (
      <div className="tab-body">
        {error ? <p className="error">{error}</p> : <p className="muted">Deriving…</p>}
      </div>
    );
  }

  const currentLabel = labels[String(active)];

  if (showAll) {
    return (
      <div className="tab-body">
        <div className="receive-list-header">
          <button className="ghost" onClick={() => setShowAll(false)}>
            ← Back
          </button>
          <h3>Your addresses</h3>
        </div>
        <ul className="address-list">
          {addresses.map((a) => {
            const lbl = labels[String(a.index)];
            return (
              <li
                key={a.index}
                className={a.index === active ? "active" : ""}
                onClick={() => void pickAddress(a.index)}
                style={{ cursor: "pointer" }}
              >
                <span className="address-index">#{a.index}</span>
                <div className="address-block">
                  {lbl && <div className="address-label">{lbl}</div>}
                  <code>{a.address}</code>
                </div>
                <span className="small ok">{a.index === active ? "✓" : ""}</span>
              </li>
            );
          })}
        </ul>
        <button className="secondary" onClick={() => void nextAddress()}>
          Generate next address
        </button>
      </div>
    );
  }

  return (
    <div className="tab-body">
      <div className="receive-card">
        <div className="receive-card-header">
          <div>
            {currentLabel && !editing ? (
              <div className="address-label" onClick={startEditLabel} style={{ cursor: "pointer" }}>
                {currentLabel} <span className="muted small">edit</span>
              </div>
            ) : !editing ? (
              <button className="ghost" onClick={startEditLabel}>
                + add label
              </button>
            ) : null}
            {editing && (
              <div className="row">
                <input
                  type="text"
                  value={editingLabel}
                  autoFocus
                  placeholder="Label (e.g. Exchange)"
                  onChange={(e) => setEditingLabel(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter") void saveEditLabel();
                    if (e.key === "Escape") setEditing(false);
                  }}
                />
                <button onClick={() => void saveEditLabel()}>OK</button>
              </div>
            )}
          </div>
          <span className="address-index">#{active}</span>
        </div>

        <div className="qr-wrap">
          <Qr data={activeAddr.address} size={196} />
        </div>

        <code className="receive-address">{activeAddr.address}</code>

        <div className="row">
          <button onClick={() => void copy(activeAddr.address)}>
            {copied ? "Copied ✓" : "Copy address"}
          </button>
          <button className="secondary" onClick={() => void nextAddress()}>
            New address
          </button>
        </div>
        <button className="ghost" onClick={() => setShowAll(true)}>
          See all derived addresses
        </button>
      </div>
      {error && <p className="error">{error}</p>}
    </div>
  );
}

function DevTab({ wallet }: { wallet: StoredWallet }) {
  const [signMessage, setSignMessage] = useState<string>("hello world");
  const [signature, setSignature] = useState<string | null>(null);
  const [signError, setSignError] = useState<string | null>(null);
  const [signing, setSigning] = useState(false);

  const [decodeInput, setDecodeInput] = useState<string>("");
  const [decoded, setDecoded] = useState<{ puzzle_hash: string; prefix: string } | null>(null);
  const [decodeError, setDecodeError] = useState<string | null>(null);

  const onSign = async () => {
    setSigning(true);
    setSignature(null);
    setSignError(null);
    try {
      const messageHex = toHex(signMessage);
      const res = await callEngine<{ signature: string }>("sign_message", {
        fingerprint: wallet.fingerprint,
        index: 0,
        message: messageHex,
      });
      setSignature(res.signature);
    } catch (err) {
      setSignError((err as Error).message);
    } finally {
      setSigning(false);
    }
  };

  const onDecode = async () => {
    setDecoded(null);
    setDecodeError(null);
    try {
      const res = await callEngine<{ puzzle_hash: string; prefix: string }>("decode_address", {
        address: decodeInput.trim(),
      });
      setDecoded(res);
    } catch (err) {
      setDecodeError((err as Error).message);
    }
  };

  return (
    <div className="tab-body">
      <h3>Sign message</h3>
      <input
        type="text"
        value={signMessage}
        onChange={(e) => setSignMessage(e.target.value)}
      />
      <button onClick={onSign} disabled={signing || !signMessage}>
        {signing ? "Signing…" : "Sign with index 0"}
      </button>
      {signature && (
        <div className="result">
          <div>
            <span className="muted">signature</span>
            <code>{signature}</code>
          </div>
        </div>
      )}
      {signError && <p className="error">{signError}</p>}

      <h3>Decode address</h3>
      <input
        type="text"
        value={decodeInput}
        onChange={(e) => setDecodeInput(e.target.value)}
        placeholder="xch1…"
      />
      <button onClick={onDecode} disabled={!decodeInput.trim()}>
        Decode
      </button>
      {decoded && (
        <div className="result">
          <div>
            <span className="muted">prefix</span>
            <code>{decoded.prefix}</code>
          </div>
          <div>
            <span className="muted">puzzle hash</span>
            <code>{decoded.puzzle_hash}</code>
          </div>
        </div>
      )}
      {decodeError && <p className="error">{decodeError}</p>}
    </div>
  );
}

function toHex(str: string): string {
  const bytes = new TextEncoder().encode(str);
  return Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
}

import { useEffect, useState } from "react";
import { callEngine, setActiveWallet } from "../../src/popup/engine-client";
import {
  getActiveFingerprint,
  listWallets,
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
      // Unlock the engine immediately so the home screen has the SK cached.
      await callEngine("unlock_keychain", {
        keychain_blob: importRes.keychain_blob,
        fingerprint: importRes.fingerprint,
        password,
      });
      const wallet: StoredWallet = {
        fingerprint: importRes.fingerprint,
        keychainBlob: importRes.keychain_blob,
        label: `Wallet ${importRes.fingerprint}`,
        createdAt: Date.now(),
      };
      await saveWallet(wallet);
      await onDone(wallet);
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
        <button onClick={() => setMode("import")}>Import existing mnemonic</button>
      </section>
    );
  }

  return (
    <section className="screen">
      <h1>{mode === "create" ? "Save your seed phrase" : "Import mnemonic"}</h1>
      {mode === "create" && (
        <p className="muted">
          Write these 24 words down somewhere safe. They're the only way to recover your wallet.
        </p>
      )}
      <textarea
        value={mnemonic}
        onChange={(e) => setMnemonic(e.target.value)}
        rows={4}
        spellCheck={false}
        readOnly={mode === "create"}
      />
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
        <button onClick={() => setMode("choose")} disabled={busy}>
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

interface SyncInfo {
  peak_height: number;
  synced: boolean;
  mempool_size: number;
}

function HomeScreen({
  wallet,
  onLock,
}: {
  wallet: StoredWallet;
  onLock: () => void | Promise<void>;
}) {
  const [tab, setTab] = useState<"home" | "receive" | "dev">("home");
  const [sync, setSync] = useState<SyncInfo | null>(null);
  const [syncError, setSyncError] = useState<string | null>(null);

  const refreshSync = async () => {
    try {
      const res = await callEngine<SyncInfo>("sync_tick", { endpoint: "mainnet" });
      setSync(res);
      setSyncError(null);
    } catch (err) {
      setSyncError((err as Error).message);
    }
  };

  useEffect(() => {
    void refreshSync();
    const id = setInterval(() => {
      void refreshSync();
    }, 30_000);
    return () => clearInterval(id);
  }, []);

  return (
    <section className="screen">
      <div className="wallet-bar">
        <div>
          <h1 className="balance">0.0000 XCH</h1>
          <p className="muted">
            {wallet.label} · fp {wallet.fingerprint}
          </p>
        </div>
        <div className="sync-badge">
          {sync ? (
            <>
              <span className={sync.synced ? "ok" : "warn"}>
                {sync.synced ? "synced" : "syncing"}
              </span>
              <code>#{sync.peak_height.toLocaleString()}</code>
              <span className="muted small">mempool {sync.mempool_size}</span>
            </>
          ) : syncError ? (
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
          className={tab === "receive" ? "tab active" : "tab"}
          onClick={() => setTab("receive")}
        >
          Receive
        </button>
        <button
          className={tab === "dev" ? "tab active" : "tab"}
          onClick={() => setTab("dev")}
        >
          Dev
        </button>
      </nav>

      {tab === "home" && <HomeTab />}
      {tab === "receive" && <ReceiveTab wallet={wallet} />}
      {tab === "dev" && <DevTab wallet={wallet} />}

      <button onClick={() => void onLock()} className="lock-btn">
        Lock
      </button>
    </section>
  );
}

function HomeTab() {
  return (
    <div className="tab-body">
      <p className="muted">
        Balance + recent activity will live here once the sync loop wires
        coinset.org coin records into IndexedDB.
      </p>
      <ul className="status-list">
        <li>
          <span className="muted">XCH</span>
          <span>—</span>
        </li>
        <li>
          <span className="muted">CATs</span>
          <span>—</span>
        </li>
        <li>
          <span className="muted">NFTs</span>
          <span>—</span>
        </li>
      </ul>
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
  const [error, setError] = useState<string | null>(null);
  const [copiedIndex, setCopiedIndex] = useState<number | null>(null);

  useEffect(() => {
    void (async () => {
      try {
        const res = await callEngine<{ addresses: DerivedAddress[] }>("derive_addresses", {
          fingerprint: wallet.fingerprint,
          start: 0,
          count: 10,
          testnet: false,
        });
        setAddresses(res.addresses);
      } catch (err) {
        setError((err as Error).message);
      }
    })();
  }, [wallet.fingerprint]);

  const copy = async (addr: DerivedAddress) => {
    try {
      await navigator.clipboard.writeText(addr.address);
      setCopiedIndex(addr.index);
      setTimeout(() => setCopiedIndex(null), 1500);
    } catch {
      // clipboard may be denied
    }
  };

  return (
    <div className="tab-body">
      <p className="muted">
        Send XCH or CATs to any of these addresses. They all belong to your
        wallet — you can rotate freely.
      </p>
      {error && <p className="error">{error}</p>}
      <ul className="address-list">
        {addresses.map((a) => (
          <li key={a.index}>
            <span className="address-index">#{a.index}</span>
            <code>{a.address}</code>
            <button onClick={() => void copy(a)}>
              {copiedIndex === a.index ? "Copied" : "Copy"}
            </button>
          </li>
        ))}
      </ul>
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

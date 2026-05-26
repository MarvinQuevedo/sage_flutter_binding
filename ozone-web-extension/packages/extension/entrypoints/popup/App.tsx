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
      const res = await callEngine<{
        fingerprint: number;
        keychain_blob: string;
        address_0: string;
        master_public_key: string;
      }>("import_mnemonic", {
        mnemonic: mnemonic.trim(),
        password,
        testnet: false,
      });
      const wallet: StoredWallet = {
        fingerprint: res.fingerprint,
        keychainBlob: res.keychain_blob,
        label: `Wallet ${res.fingerprint}`,
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

function HomeScreen({
  wallet,
  onLock,
}: {
  wallet: StoredWallet;
  onLock: () => void | Promise<void>;
}) {
  const [address, setAddress] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    void (async () => {
      try {
        // For now derive locally without the unlocked SK — uses the keychain
        // blob's master_pk path. Once the unlock holds the SK in memory this
        // method will be redundant.
        const res = await callEngine<{ address: string }>("derive_address", {
          // dev placeholder: use a known mnemonic. In the real flow this comes
          // from the unlocked SK held by the engine.
          mnemonic:
            "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
          index: 0,
          testnet: false,
        });
        setAddress(res.address);
      } catch (err) {
        setError((err as Error).message);
      }
    })();
  }, []);

  return (
    <section className="screen">
      <h1>0.0000 XCH</h1>
      <p className="muted">
        {wallet.label} · fp {wallet.fingerprint}
      </p>
      {address && (
        <div className="result">
          <div>
            <span className="muted">receive address</span>
            <code>{address}</code>
          </div>
        </div>
      )}
      {error && <p className="error">{error}</p>}
      <nav className="actions">
        <button disabled>Send</button>
        <button disabled>Receive</button>
      </nav>
      <button onClick={() => void onLock()} className="lock-btn">
        Lock
      </button>
    </section>
  );
}

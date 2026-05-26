import { defineConfig } from "wxt";

export default defineConfig({
  modules: ["@wxt-dev/module-react"],
  srcDir: ".",
  outDir: ".output",
  manifest: {
    name: "Ozone",
    description: "Chia wallet — Goby-compatible, coinset.org-synced.",
    version: "0.0.1",
    manifest_version: 3,
    permissions: ["storage", "alarms", "tabs"],
    host_permissions: [
      "https://api.coinset.org/*",
      "https://kraken.fireacademy.io/*",
      "https://api.dexie.space/*",
      "https://*.mintgarden.io/*",
      "https://ipfs.io/*",
      "https://*.ipfs.dweb.link/*",
    ],
    action: {
      default_title: "Ozone",
      default_popup: "popup.html",
    },
    background: {
      service_worker: "background.js",
      type: "module",
    },
    web_accessible_resources: [
      {
        resources: ["inpage.js"],
        matches: ["<all_urls>"],
      },
    ],
    content_security_policy: {
      extension_pages:
        "script-src 'self' 'wasm-unsafe-eval'; object-src 'self';",
    },
  },
});

// Dexie CAT metadata client.
//
// Dexie's public REST API exposes per-asset metadata (name, ticker, image)
// for every CAT they index. We use it to put a human face on the raw
// asset_id hashes the engine surfaces from scan_cats.
//
// Cached per asset_id in chrome.storage.local["dexie.cats"] with a TTL so
// we don't hammer the API on every popup open.

const CACHE_KEY = "dexie.cats";
const CACHE_TTL_MS = 12 * 60 * 60 * 1000; // 12 hours

export interface DexieCat {
  asset_id: string;
  code?: string;
  name?: string;
  image_url?: string;
  decimals?: number;
  fetched_at: number;
}

type Cache = Record<string, DexieCat>;

async function loadCache(): Promise<Cache> {
  const data = await chrome.storage.local.get(CACHE_KEY);
  return (data[CACHE_KEY] as Cache | undefined) ?? {};
}

async function saveCache(cache: Cache): Promise<void> {
  await chrome.storage.local.set({ [CACHE_KEY]: cache });
}

function normalizeAssetId(id: string): string {
  return id.toLowerCase().replace(/^0x/, "");
}

/**
 * Resolve metadata for a batch of asset_ids. Returns whatever is in cache +
 * what we could fetch; missing assets fall back to the raw hash. Errors are
 * swallowed (best-effort) so a Dexie outage never breaks the wallet UI.
 */
export async function resolveCatMetadata(
  assetIds: string[],
): Promise<Record<string, DexieCat>> {
  if (assetIds.length === 0) return {};
  const cache = await loadCache();
  const now = Date.now();
  const result: Record<string, DexieCat> = {};
  const toFetch: string[] = [];

  for (const id of assetIds) {
    const key = normalizeAssetId(id);
    const cached = cache[key];
    if (cached && now - cached.fetched_at < CACHE_TTL_MS) {
      result[id] = cached;
    } else {
      toFetch.push(key);
    }
  }

  if (toFetch.length > 0) {
    try {
      // Dexie public API — single-CAT lookup (the bulk endpoint requires
      // payment; the per-id endpoint is free + caches well).
      const fetched = await Promise.all(
        toFetch.map(async (key) => {
          try {
            const res = await fetch(`https://api.dexie.space/v1/assets/${key}`);
            if (!res.ok) return null;
            const body = await res.json();
            // Shape (Dexie v1): { success, asset: { id, code, name, image, ... } }
            const asset = body?.asset ?? body;
            if (!asset || typeof asset !== "object") return null;
            const meta: DexieCat = {
              asset_id: key,
              code: typeof asset.code === "string" ? asset.code : undefined,
              name: typeof asset.name === "string" ? asset.name : undefined,
              image_url:
                typeof asset.image === "string"
                  ? asset.image
                  : typeof asset.image_url === "string"
                    ? asset.image_url
                    : undefined,
              decimals: typeof asset.decimals === "number" ? asset.decimals : 3,
              fetched_at: now,
            };
            return meta;
          } catch {
            return null;
          }
        }),
      );
      for (const meta of fetched) {
        if (meta) {
          cache[meta.asset_id] = meta;
          // Echo into result by both stripped and 0x-prefixed forms
          result[meta.asset_id] = meta;
          result[`0x${meta.asset_id}`] = meta;
        }
      }
      await saveCache(cache);
    } catch {
      // best-effort
    }
  }

  return result;
}

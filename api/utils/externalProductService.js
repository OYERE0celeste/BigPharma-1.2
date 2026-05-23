const logger = require("./logger");
const cache = require("./cache");

const DEFAULT_TIMEOUT_MS = 10000;
const CACHE_PREFIX = "external_product_lookup:";
const CACHE_TTL_SECONDS = 60 * 60; // 1 hour

const buildUrl = (template, code) => {
  if (!template) return null;
  return template.replace(/\{\{\s*barcode\s*\}\}/gi, encodeURIComponent(code));
};

const fetchJson = async (uri, options = {}) => {
  if (!uri) return null;

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), DEFAULT_TIMEOUT_MS);

  try {
    const response = await fetch(uri, {
      method: "GET",
      headers: {
        Accept: "application/json",
        "User-Agent": "BigPharma API Lookup Service",
        ...options.headers,
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      return null;
    }

    const body = await response.text();
    return JSON.parse(body);
  } catch (error) {
    if (error.name === "AbortError") {
      logger.warn(`External lookup timeout for ${uri}`);
    } else {
      logger.warn(`External lookup error for ${uri}: ${error.message}`);
    }
    return null;
  } finally {
    clearTimeout(timeout);
  }
};

const normalizeBarcode = (raw) => {
  if (!raw || typeof raw !== "string") return null;
  return raw.replace(/\s+/g, "").trim();
};

const isUrl = (value) => {
  if (!value || typeof value !== "string") return false;
  try {
    new URL(value);
    return true;
  } catch {
    return false;
  }
};

const tryParseJson = (raw) => {
  if (!raw || typeof raw !== "string") return null;
  try {
    const parsed = JSON.parse(raw);
    return parsed && typeof parsed === "object" ? parsed : null;
  } catch {
    return null;
  }
};

const fetchText = async (uri, options = {}) => {
  if (!uri) return null;

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), DEFAULT_TIMEOUT_MS);
  try {
    const response = await fetch(uri, {
      method: "GET",
      headers: {
        Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "User-Agent": "BigPharma API Lookup Service",
        ...options.headers,
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      return null;
    }

    return await response.text();
  } catch (error) {
    if (error.name === "AbortError") {
      logger.warn(`Web metadata timeout for ${uri}`);
    } else {
      logger.warn(`Web metadata error for ${uri}: ${error.message}`);
    }
    return null;
  } finally {
    clearTimeout(timeout);
  }
};

const extractMetaFromHtml = (html, propertyPattern) => {
  const regex = new RegExp(
    `<meta[^>]+(?:property|name)\s*=\s*['\"]${propertyPattern}['\"][^>]+content\s*=\s*['\"]([^'\"]+)['\"]`,
    "i",
  );
  const match = regex.exec(html);
  return match ? match[1].trim() : null;
};

const parseWebMetadata = async (uri) => {
  const html = await fetchText(uri);
  if (!html) return null;

  const title =
    extractMetaFromHtml(html, "og:title") ??
    extractMetaFromHtml(html, "twitter:title") ??
    (html.match(/<title[^>]*>([^<]+)<\/?title>/i)?.[1] ?? null);
  if (!title) return null;

  const description =
    extractMetaFromHtml(html, "og:description") ??
    extractMetaFromHtml(html, "twitter:description") ??
    extractMetaFromHtml(html, "description");
  const imageUrl =
    extractMetaFromHtml(html, "og:image") ??
    extractMetaFromHtml(html, "twitter:image");

  return {
    name: title,
    description,
    imageUrl,
    category: uri.hostname,
  };
};

const buildLookupPayload = (source, barcode, data) => ({
  source,
  barcode,
  name: data.name || data.product_name || data.title || data.description || null,
  brand: data.brand || data.manufacturer || data.maker || null,
  manufacturer: data.manufacturer || data.laboratory || null,
  dosage: data.dosage || data.strength || data.dose || null,
  quantity: data.quantity || data.size || data.packaging || null,
  category: data.category || data.type || data.product_type || null,
  description: data.description || data.summary || data.ingredients || null,
  imageUrl: data.image || data.image_url || data.imageUrl || data.image_front_url || null,
  externalId: data.id || data.product_id || data.upc || null,
  ingredients: data.ingredients || data.active_ingredients || null,
  rawData: data,
});

const lookupDrugsApi = async (barcode) => {
  const urlTemplate = process.env.DRUGS_API_URL || "";
  const apiKey = process.env.DRUGS_API_KEY || "";
  if (!urlTemplate || !apiKey) return null;

  const url = buildUrl(urlTemplate, barcode);
  if (!url) return null;

  const response = await fetchJson(url, {
    headers: {
      Authorization: `Bearer ${apiKey}`,
    },
  });
  if (!response) return null;

  return buildLookupPayload("DrugsAPI", barcode, response);
};

const lookupGoUpc = async (barcode) => {
  const urlTemplate = process.env.GO_UPC_API_URL || "";
  const apiKey = process.env.GO_UPC_API_KEY || "";
  if (!urlTemplate || !apiKey) return null;

  const url = buildUrl(urlTemplate, barcode);
  if (!url) return null;

  const response = await fetchJson(url, {
    headers: {
      Authorization: `Bearer ${apiKey}`,
    },
  });
  if (!response) return null;

  return buildLookupPayload("Go-UPC", barcode, response);
};

const lookupOpenFoodFacts = async (barcode) => {
  const url = `https://world.openfoodfacts.net/api/v3/product/${encodeURIComponent(barcode)}?fields=product_name,product_name_fr,generic_name,brands,brands_tags,categories,categories_tags,image_front_small_url,image_front_url,image_url,ingredients_text,ingredients_text_fr`;
  const response = await fetchJson(url);
  if (!response || response.status !== "success" || !response.product) return null;

  return buildLookupPayload("OpenFoodFacts", barcode, response.product);
};

const lookupBarcode = async (rawBarcode) => {
  const barcode = normalizeBarcode(rawBarcode);
  if (!barcode) return null;

  const cacheKey = `${CACHE_PREFIX}${barcode}`;
  const cached = await cache.get(cacheKey);
  if (cached) {
    return cached;
  }

  let lookup = await lookupDrugsApi(barcode);
  if (!lookup) {
    lookup = await lookupGoUpc(barcode);
  }
  if (!lookup) {
    lookup = await lookupOpenFoodFacts(barcode);
  }

  if (lookup) {
    await cache.set(cacheKey, lookup, CACHE_TTL_SECONDS);
  }

  return lookup;
};

const lookupQrCode = async (rawValue) => {
  const trimmed = rawValue?.trim();
  if (!trimmed) return null;

  const jsonPayload = tryParseJson(trimmed);
  if (jsonPayload) {
    return buildLookupPayload("QR Payload", trimmed, jsonPayload);
  }

  if (isUrl(trimmed)) {
    const uri = new URL(trimmed);
    const metadata = await parseWebMetadata(uri);
    if (!metadata) return null;

    return buildLookupPayload("WebMetadata", trimmed, {
      ...metadata,
      barcode: trimmed,
    });
  }

  return null;
};

const lookupCode = async (rawCode) => {
  if (!rawCode || typeof rawCode !== "string") return null;

  if (isUrl(rawCode.trim()) || tryParseJson(rawCode.trim())) {
    return await lookupQrCode(rawCode);
  }

  return await lookupBarcode(rawCode);
};

module.exports = {
  lookupBarcode,
  lookupCode,
};

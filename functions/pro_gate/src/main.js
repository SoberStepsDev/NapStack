/**
 * NapStack — Appwrite Function: pro_gate
 *
 * Weryfikuje status Pro użytkownika przez RevenueCat REST API v2.
 * Wywoływana przed każdą akcją zarezerwowaną dla Pro (fullCycle, nap_stack > 3).
 *
 * Oczekiwane ENV (ustawiane w panelu Appwrite → Functions → Variables):
 *   RC_SECRET_KEY_ANDROID  — RevenueCat V2 Secret API Key (nie Public Key!)
 *   RC_PROJECT_ID          — RevenueCat project ID (dla V2 API)
 *   PRO_ENTITLEMENT_ID     — identyfikator entitlement (domyślnie: "pro")
 *
 * Request (HTTP POST z Flutter):
 *   Header: x-appwrite-user-id  (wstrzykiwany automatycznie przez Appwrite)
 *   Body JSON: { "action": "fullCycle" | "addToStack" }
 *
 * Response JSON:
 *   { "allowed": true  }  — użytkownik ma aktywne Pro
 *   { "allowed": false, "reason": "not_pro" }  — brak aktywnego Pro
 *   { "allowed": false, "reason": "error", "detail": "..." }  — błąd
 *
 * Bezpieczeństwo:
 *   - userId pobierany WYŁĄCZNIE z nagłówka Appwrite (nie z body) — nie można sfałszować.
 *   - RC Secret Key nigdy nie trafia do klienta.
 *   - Funkcja jest "any" auth (wymaga zalogowanego użytkownika Appwrite).
 */

import { Client, Users } from 'node-appwrite';

const RC_ENTITLEMENT = process.env.PRO_ENTITLEMENT_ID ?? 'pro';
const RC_SECRET_KEY  = process.env.RC_SECRET_KEY_ANDROID ?? '';
const RC_PROJECT_ID  = process.env.RC_PROJECT_ID ?? '';

/**
 * Pobiera customerInfo z RevenueCat REST API v2.
 * https://www.revenuecat.com/reference/v2
 */
async function fetchRCCustomerInfo(appUserId) {
  const url = `https://api.revenuecat.com/v2/projects/${RC_PROJECT_ID}/customers/${encodeURIComponent(appUserId)}`;

  const res = await fetch(url, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${RC_SECRET_KEY}`,
      'Accept':        'application/json',
    },
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`RevenueCat HTTP ${res.status}: ${text}`);
  }

  return res.json();
}

/**
 * Sprawdza czy entitlement jest aktywny w odpowiedzi RC v2.
 *
 * RC v2 zwraca listę entitlements w:
 *   data.subscriber.entitlements[]  →  { id, object, ..., expires_date }
 * Aktywne = expires_date jest null lub w przyszłości.
 */
function isEntitlementActive(customerData) {
  const entitlements = customerData?.subscriber?.entitlements ?? [];
  const now = Date.now();

  return entitlements.some((e) => {
    if (e.id !== RC_ENTITLEMENT) return false;
    // null = lifetime (nie wygasa nigdy)
    if (e.expires_date === null) return true;
    return new Date(e.expires_date).getTime() > now;
  });
}

export default async ({ req, res, log, error }) => {
  // ── Walidacja konfiguracji ──────────────────────────────────────────────────
  if (!RC_SECRET_KEY || !RC_PROJECT_ID) {
    error('Brakujące ENV: RC_SECRET_KEY_ANDROID lub RC_PROJECT_ID');
    return res.json({ allowed: false, reason: 'error', detail: 'misconfigured' }, 500);
  }

  // ── userId z nagłówka Appwrite (nie można sfałszować) ─────────────────────
  const userId = req.headers['x-appwrite-user-id'];
  if (!userId) {
    return res.json({ allowed: false, reason: 'error', detail: 'missing_user_id' }, 401);
  }

  // ── Akcja (opcjonalna — logujemy dla auditu) ───────────────────────────────
  const body   = req.body ? JSON.parse(req.body) : {};
  const action = body.action ?? 'unknown';

  log(`[pro_gate] userId=${userId} action=${action}`);

  // ── Zapytanie do RevenueCat ────────────────────────────────────────────────
  try {
    const customerData = await fetchRCCustomerInfo(userId);
    const allowed      = isEntitlementActive(customerData);

    log(`[pro_gate] userId=${userId} allowed=${allowed}`);

    if (allowed) {
      return res.json({ allowed: true });
    } else {
      return res.json({ allowed: false, reason: 'not_pro' });
    }
  } catch (err) {
    error(`[pro_gate] RC error for userId=${userId}: ${err.message}`);
    return res.json({ allowed: false, reason: 'error', detail: err.message }, 502);
  }
};

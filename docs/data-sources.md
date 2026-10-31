# App data sources

The app no longer bundles example records, phone numbers, courier credentials,
admin territories, analytics, map coordinates, stock photos, or login fallbacks.
Examples used by automated tests are in `test/fixtures/` and are explicitly
injected by tests. Production constructors start with empty collections.

- Login requires a valid API response. Rejections, offline errors, timeouts and
  malformed responses do not authenticate the user.
- Registration must succeed remotely. It does not issue tokens, so the user then
  signs in. Branch fields have no example defaults; failed gender lookup offers
  retry. No local WhatsApp membership is manufactured.
- Home services, banners, advertisements, organisations, emergency contacts and
  Buy & Sell retain their existing API integrations. No sample contacts replace
  an error. Missing photos show neutral placeholders.
- Books, rides, videos, delivery requests and non-API marketplace catalogs start
  empty. User-entered records and attachments retain their existing session-only
  behavior; removing seeds does not add persistence or new API endpoints.
- The legacy village directory has no connected backend and returns no records.
  Registration uses the branch specified in its existing API form instead.
- Admin and delivery sign-in had only account-selection/PIN demos. They cannot
  create sessions until real authenticated account/role integrations are added.
- Checkout had only an in-memory demo order generator. It now reports unavailable
  and preserves the cart; it does not claim payment, ordering or fulfilment.

Verification covers local repository state and HTTP-client test responses, not
live backend availability or production role assignment.

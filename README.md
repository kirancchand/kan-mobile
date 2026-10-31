# Village Connect — Mobile App

Flutter implementation of the Village Community Mobile App described in
[`village-app-concept.md`](./village-app-concept.md).

**Current data behavior:** bundled demo records and authentication fallbacks have
been removed. API failures surface as errors; local service catalogs start empty
and contain only user-entered records. Sample fixtures exist only under `test/`.
Registration requires a successful API response followed by login; no WhatsApp
group is synthesized. Admin/delivery sign-in and checkout are unavailable until
real backend integrations exist. No demo order is created. See
[`docs/data-sources.md`](docs/data-sources.md) for the current limitations.

The feature descriptions below include historical prototype behavior; this
current-data policy supersedes references to demo accounts, automatic groups,
fallback login, and demo checkout.

## Requirements

- Flutter 3.47+ / Dart 3.13+ (this project was built and analyzed against
  Flutter 3.47.5)
- Android SDK (for Android) and/or Chrome (for quick web testing)

## Running it

Use the installed SDK at
`/home/kirancchand/Desktop/install/flutter/flutter_linux_3.29/flutter`.
Despite the directory name, it currently contains Flutter 3.47.5 / Dart 3.13.4.
The default `flutter` on PATH is older and incompatible; project instructions
in `AGENTS.md` record this choice for future sessions.

```bash
export PATH="/home/kirancchand/Desktop/install/flutter/flutter_linux_3.29/flutter/bin:$PATH"
flutter pub get
flutter run              # pick a connected device/emulator
flutter run -d chrome    # fastest way to try it — no emulator needed
```

Run `flutter analyze` and `flutter test` with the SDK above; see the latest validation results for known failures.

## What's implemented

Every section of the concept doc maps to code as follows:

| Concept doc section | Where it lives |
|---|---|
| §1 Home Page (ads, events, services, emergency contacts, shops directory) | `lib/features/home/` |
| §2 Services (all 8 mini-marketplaces) | `lib/features/services/` |
| §3 Mock-data-first architecture | `lib/data/repositories/*` — every screen calls a repository, never mock data directly, so Phase 2 only means swapping repository internals for real API calls |
| §4 Location DB + WhatsApp group auto-assignment | `lib/data/repositories/whatsapp_group_repository.dart` (assignment logic), `lib/features/onboarding/` (registration flow that triggers it) |
| §5 Admin Panel & location hierarchy | `lib/features/admin/` (separate login from resident flow; Location Admin vs. Head Admin) |
| §6 App structure | Mirrors the doc's tree — see `lib/features/root_shell.dart` for the 4-tab shell (Home / Services / Profile / Admin) |

### Services (§2) — how the 8 modules are covered

Rather than 8 bespoke screens copy-pasting the same list/detail/post pattern,
services are grouped by shape:

- **Buy & Sell** has dedicated blue glass browse/detail screens in
  `lib/features/services/buy_sell/`, using `MarketplaceRepository` and the
  shared marketplace posting form with its local theme.
- **Plants**, **Cake Marketplace**, and **Pharmacy** have dedicated browse/detail
  layouts in `lib/features/services/plants/`, `lib/features/services/cake/`, and
  `lib/features/services/pharmacy/`. They share
  `MarketplaceRepository` and the marketplace posting form, styled with each
  feature’s theme.
- **Ride Pool** is one service in `lib/features/services/ride_pool/`. Browse
  all rides or filter by **Car** / **Bike**, and choose the vehicle type when
  offering a ride. Listings and ride details display the chosen type.
  `VehicleType` stores this choice separately from `ServiceType`.
- **Online Library**, **Village YouTube**, and **Delivery** each get their
  own folder since their data shape and flow genuinely differ (rent-vs-buy
  books, review-before-featuring videos, pickup/drop delivery status).

`lib/features/services/service_router.dart` is the single place that knows
how to open any `ServiceType` — new services register there.

### Location & WhatsApp group logic (§4)

`WhatsAppGroupRepository` implements the exact rule from the concept doc:
no group yet → create Group 1; group has room → add to it; group is full →
spin up the next sequential group. It uses a small demo member limit (8,
not WhatsApp's 1024) purely so you can see a second group get created while
testing with a handful of mock registrations — see the constant
`WhatsAppGroupRepository.demoMemberLimit`.

### Admin Panel & hierarchy (§5)

Admin login (`lib/features/admin/admin_login_screen.dart`) is separate from
resident registration. Main, State, District, Region, Area, and Branch admins
share a dashboard scoped to their assigned territory and descendants.

- Tap **Active Users** in Statistics to see all available users in the current
  territory, including descendant branches. Search by name, phone, branch, or user type.
- Tap **Businesses** to see all available shops and organisations in that territory,
  with category, branch, address, and phone details where available.
- Both directories default to **View all users/businesses** and offer **View by
  hierarchy**. This lists immediate child territories. Selecting one opens its
  complete user/business list, with the same choices at every subsequent level.
  Back returns to the previous territory and its selected view. Branches show
  an explicit message that no lower hierarchy exists.
- The standalone **View Users** button and dashboard **Shops & Organisations**
  section are removed; the statistics cards are the directory entry points.
- Demo statistics are aggregate sample totals; directory records are available
  samples plus registrations made during the session, so counts can differ.
- Branch admins retain **Add User** and **Add Organisation**. Subadmin dashboard
  navigation and branch transaction records remain available.

### Mock data & the Phase 2 seam

Registration uses the auth API described below with a demo fallback.
Every screen depends on a repository interface (`lib/data/repositories/`),
never on `lib/data/mock/*` directly. Most repositories currently return
in-memory mock data behind a simulated network delay
(`Future.delayed(...)`). Phase 2 backend integration means replacing the
bodies of these repository methods with real HTTP calls — no screen code
should need to change.

## Design system

The visual design follows [`village-app-design-guidelines.md`](./village-app-design-guidelines.md).
Everything routes through a small set of shared building blocks so no screen
hand-rolls its own colors/spacing/icons:

| Guideline | Implementation |
|---|---|
| Material 3 theme from one seed color, light + dark | `lib/core/theme/app_theme.dart` — `ColorScheme.fromSeed`, wired to a real dark-mode toggle in Settings (`lib/state/theme_state.dart`) |
| Custom typography (not the system font) | Google Fonts "Poppins" `TextTheme`, sized per the guideline's Display/Headline/Title/Body/Caption scale, defined once in `AppTheme._textTheme` |
| Fixed spacing/radius scale | `lib/core/theme/app_spacing.dart` (`AppSpacing`, `AppRadius`) |
| Soft-shadow cards (not flat Material elevation) | `lib/core/widgets/app_card.dart` — drop-in `Card` replacement used everywhere |
| One consistent icon family | `lib/core/theme/app_icons.dart` — see note below |
| Real photos over generic icons | `imageUrl`/`coverUrl`/`thumbnailUrl` getters on the relevant models (deterministic `picsum.photos` placeholders for this mock-data phase), rendered via `lib/core/widgets/app_network_image.dart` (cached, shimmer placeholder, error fallback) |
| Shimmer loading skeletons instead of bare spinners | `lib/core/widgets/shimmer_list_placeholder.dart`, used in every list/dashboard `FutureBuilder` |
| Short, snappy motion | `flutter_animate` fade/slide-in on list items (staggered by index) and screen content, plus `Hero` transitions from list thumbnails into detail screens (marketplace listings, book covers) |

**Icon system note:** the guideline suggests `phosphor_flutter` or
`lucide_icons`. Both generate their `IconData` by subclassing it, which the
Flutter/Dart SDK this project targets no longer allows (`IconData` is a
`final class`). `AppIcons` sidesteps that by building `IconData` values
directly from Phosphor's font codepoints — `phosphor_flutter` stays a
pubspec dependency purely so its font files get bundled, but no code
imports its (currently broken) Dart API. If a future `phosphor_flutter`
release fixes this upstream, `AppIcons` can be deleted and call sites
pointed back at the package directly.

## Open items from the concept doc (§7) not yet resolved

These are intentionally left as-is since the doc marks them "to be
decided": phone/OTP verification (registration submits the
Postman profile fields to the auth API), payments, WhatsApp Business API wiring (currently
simulated), and moderation/approval workflows beyond the basic
pending/approved/featured status on video submissions.


### Ride Pool visual reference

The Ride Pool feature follows [`samples/ride pool.jpg`](<samples/ride pool.jpg>) with indigo glass panels, lavender/blue/peach gradients, frosted route cards, and orange actions. `RidePoolGlass` provides real clipped backdrop blur, translucent surfaces, highlight borders and soft shadows across search, filters, ride details, the offer form and bottom actions. Users can search by origin/destination, filter Car/Bike, sort by departure or price, and offer a ride. The local `ride_pool_theme.dart` palette also styles ride details and the offer form, including dark mode. See `design.md` and `village-app-design-guidelines.md` for the reference rules.


### Plants visual references

Plants uses [`samples/plant1.jpg`](samples/plant1.jpg) and [`samples/plant2.jpg`](samples/plant2.jpg) as visual references. `lib/features/services/plants/` provides mint/cream/sage gradients, forest-green buttons, botanical illustrations, searchable plant cards, category filters, and matching detail/posting screens. `PlantsGlass` adds real clipped backdrop blur, translucent panels, highlight borders and soft shadows to cards, search, detail sections, the form and bottom actions. It retains `MarketplaceRepository` and the shared posting form. Artwork is illustrative; seller descriptions and contact details remain the source of listing information. Both light and dark modes are supported.


### Cake Marketplace visual reference

Cake Marketplace follows [`samples/cake.jpg`](samples/cake.jpg): warm cream surfaces, raspberry actions, pink/peach gradients, rounded dessert cards, and a large product illustration. `CakeGlass` adds real clipped backdrop blur, translucent panels, bright borders and soft shadows across browsing, product details, posting and bottom actions. `lib/features/services/cake/` owns the local theme and browse/detail screens. Users can search titles, flavours and bakers, filter by listing category, open the featured cake, view prices in rupees, contact a baker, and list a cake through the shared form. Newly posted listings refresh the catalog. Light and dark modes are supported. Cake artwork is a bundled Flutter illustration, labeled on the detail page; uploaded media appears on cards and in detail galleries; illustrations remain fallbacks.


### Online Library visual reference

Online Library follows [`samples/book.jpg`](samples/book.jpg) with an aqua/pastel palette and glassmorphic surfaces. `library_theme.dart` provides real clipped backdrop blur, translucent cards, highlighted borders, and light/dark backgrounds across browsing, book details, and posting. Search by title, author, or genre; filter rentals, sales, and wanted books. Newest books appear on a horizontal shelf with a full community collection below. Covers are local typographic demo artwork; prices and owner/buyer contact information come from `BookRepository`.


### Pharmacy visual references

The former Medicine module is now **Pharmacy** (`ServiceType.pharmacy`), including service navigation, mock listings, profile aggregation and admin labels. It follows [`samples/medicine.jpg`](samples/medicine.jpg) and [`samples/pharmacy.jpg`](samples/pharmacy.jpg): teal accents, mint/cyan backgrounds, illustrated product cards and local pharmacy contacts. `PharmacyGlass` adds clipped 14px backdrop blur, translucent surfaces, highlight borders and soft shadows across browsing, details, posting and bottom actions. Search products/categories/sellers, filter categories, contact a pharmacy, and post a product through the shared marketplace form. Light/dark modes and enlarged text are supported.


### Latest across services — home slider

Home shows one swipeable card for each of the eight services, above the service grid. `LatestEntriesRepository` loads the existing repositories concurrently and selects the newest creation per service: listing/book/ride `postedAt`, video `submittedAt`, and delivery `requestedAt`. Ride departures do not determine recency. Cards show the service, title, summary and relative timestamp, with swipe and previous/next controls plus animated page indicators matching `AdCarousel`. The slider advances automatically every five seconds, loops back to the first card, and restarts its interval after navigation. Advancement pauses during scrolling, on other routes, while the app is inactive, and when reduced motion is enabled. Marketplace, library and ride cards open details; YouTube and Delivery open their module lists. Empty services keep an Explore card; individual load failures keep a Retry card without hiding the other services.

New listings, rides, books, videos and delivery requests notify the slider automatically, including posts made from another tab. Home pull-to-refresh and the section's Refresh action also reload it. Cards follow the current mock repositories' visibility and show submission/delivery status; this section does not add a separate public publishing policy.


### Buy & Sell visual reference

Buy & Sell follows [`samples/buysell.jpg`](samples/buysell.jpg): icy blue gradients, cobalt accents, a yellow selling action and rounded product tiles. `BuySellGlass` adds real clipped backdrop blur, translucent panels, highlight borders and soft shadows across search, cards, details, posting and bottom actions. Search titles/categories/sellers, filter by category, open item details, contact a seller, or post a listing and see the catalog refresh. Light/dark themes and enlarged text are supported. Product artwork is local category illustration, labelled on details; uploaded media appears on cards and in detail galleries; illustrations remain fallbacks. See `design.md` and `village-app-design-guidelines.md` for the design rules.


### Images and videos in entry forms

Every service entry form supports **Add image** and **Add video**, with image previews, file sizes, removal controls and validation. Up to five files can be attached (20 MB each, 50 MB total): JPG/JPEG, PNG, WebP, GIF, MP4, MOV and WebM. Attachments are retained with submitted listings/books/rides/videos/delivery requests and shown on their details or entry cards. Village YouTube accepts an attached video instead of a link and now saves supplied links. Uploaded files appear in a swipeable image/video gallery with a full-screen zoom and playback viewer.

The shared implementation is `lib/core/widgets/media_attachments.dart`, `lib/core/services/media_picker.dart` and `lib/data/models/media_attachment.dart`. Native selection uses Flutter's [`file_selector`](https://pub.dev/packages/file_selector). Tests mock the platform picker and exercise all eight module submissions. Device picker behavior still needs a real-device smoke test.

**Mock storage only:** selected bytes live in the same in-memory repositories as entries and are lost when the app restarts. There is no backend upload/storage endpoint in this app yet. Catalog cards show uploaded media covers and image/video counts; illustrations remain fallbacks for entries without attachments. Production storage and publishing remain future work.


### Viewing multiple images and videos

All eight modules now display complete attachment galleries. Swipe or use thumbnails/previous/next controls, see the current file and image/video counts, and open a full-screen viewer. Images support pan/zoom; videos support play/pause, seeking, timing and mute. Catalog cards show uploaded covers and counts; older entries retain their artwork. Form previews use the same viewer.

`lib/core/widgets/media_gallery.dart` owns the UI; `lib/core/services/video/` prepares local bytes for [`video_player`](https://pub.dev/packages/video_player). Only the active full-screen video loads; playback is disposed on page changes/exit and paused in the background. Native temporary video files are cleaned up after disposal. Web uses a local data URI. iOS minimum is 13.0; Android uses the installed Flutter SDK's API 24 minimum. Supported codecs vary by device/browser; unsupported playback shows a failure message. Windows/Linux playback is not supplied by this plugin. Saved YouTube/Drive links are still displayed as links, not embedded video players.

Media remains in mock session storage, with no cloud upload or persistence. Tests cover mixed-gallery navigation, player cleanup, and all eight modules at narrow widths in light/dark modes; real-device codec verification remains necessary.


## Shared cart and item purchases

All modules offering items for sale use one cart: **Buy & Sell, Plants,
Cake Marketplace, Pharmacy, and Online Library books marked For Sale**.
Open an item and choose **Add to cart**, or **Buy now** to add it and open
cart review. Existing seller contact actions remain available. The header
cart badge shows the total quantity across modules.

The cart groups entries by module and listing ID, supports quantities 1–99
and removal, and calculates totals in integer paise. Review the total,
choose **Buy items**, then **Place demo order**. Cancelling retains the cart;
a successful checkout clears it and shows an order receipt. Purchases also
appear in **Profile → My Orders / Requests**, alongside delivery requests.
Unavailable marketplace listings cannot be added and are checked again at
checkout. Rentals and wanted-book posts retain contact actions; Ride Pool,
Village YouTube, and Delivery retain their booking/submission/request flows
because they do not offer items for sale.

This is Phase 1 demo checkout: no money is charged, inventory reserved,
shipping arranged, or fulfilment guaranteed. Cart and orders live only in
memory. Account changes/sign-out clear the cart; orders remain scoped to their
buyer and sellers for the current session. App restart clears both. Quantity
limits are UI limits, not stock counts. Real purchasing needs a backend
transaction that validates prices/stock, payment processing, persistent
user-scoped orders, and fulfilment integration.

Implementation: `CartItem`/`PurchaseOrder` in `lib/data/models/cart_item.dart`,
`lib/state/cart_state.dart`, shared `PurchaseActions`, and
`lib/features/cart/`. Every future module with purchasable items must use
this shared flow rather than a separate cart.


### Purchase action alignment

Use the shared `PurchaseActions` layout on every purchasable item detail.
**Add to cart** (outlined) and **Buy now** (filled) occupy equal-width columns
with a 12 px gap and a minimum 52 px height. Place the lower-emphasis
**Contact Owner / Seller / Baker / Pharmacy** text button on a full-width
row below, separated by 8 px, with a minimum 48 px touch target. Buttons use
matching 14 px corner radii, centered labels, and the module's theme colors.
Measure the scaled label width: if both purchase buttons cannot fit, stack
them at full width with the same 12 px gap. Preserve readable enlarged text
and the existing safe-area action bar. All purchase and contact behavior
remains unchanged.


## Received orders for sellers

Open **Profile → Received Orders** to see purchases of items you posted in
Buy & Sell, Plants, Cake Marketplace, Pharmacy, or Online Library (For Sale).
The newest orders appear first, showing the order reference, date, buyer name
and phone, your item names, quantities, unit prices, subtotals, and your order
total. **Contact Buyer** opens the existing contact sheet. Empty and signed-out
states explain when orders will appear.

New listings store the posting account's ID (`sellerId` / `ownerId`). Checkout
snapshots that ownership plus the buyer's account ID, name and phone. For a
cart containing several sellers' items, each seller sees only their own lines
and subtotal. Matching uses account IDs, never display names or phone numbers;
older seeded listings without an owner ID are not assigned to an account.

The demo order ledger now survives sign-out/account switches in the same app
session. The cart is cleared on account changes; My Orders shows only the
current buyer's purchases, and Received Orders shows only the current seller's
sales. Signing back in restores that account's order view. Restarting the app
still clears all mock data. No payment is collected, delivery arranged, or
cross-device order synchronization provided; production needs persistent orders
and server-side authorization.

To try it: create a seller account and post an item, sign out and create a buyer
account, buy the item through demo checkout, then sign back into the seller
account with its phone number and open Received Orders.

Implementation: `lib/features/profile/received_orders_screen.dart`, the
account-scoped order views in `lib/state/cart_state.dart`, and ownership and
buyer snapshots in the listing and cart models. Tests exercise mixed-seller
checkout, account switching, book sales, empty states and enlarged text.


### Temporary cart confirmation

After **Add to cart**, show “<item name> added to cart” with **View cart**
for three seconds, then dismiss it automatically. The shared `PurchaseActions`
snackbar sets `persist: false` so the action button does not keep it visible.
Repeated additions replace queued confirmations. View cart still opens the
shared cart while the message is visible; the header Cart action remains
available after it disappears.


### Mark received orders ready for shipping

In **Profile → Received Orders**, each received order has a **Ready for shipping**
button. Tap it when your items are prepared: the status changes from **Received**
to **Ready for shipping**, and the button becomes disabled. Contact Buyer remains
available. For a checkout involving multiple sellers, this action updates only
your items; other sellers control their own readiness. Buyers see each item's
status in **My Orders / Requests**.

Readiness is saved in the session order ledger and survives signing out and back
in during the same app session. It resets with all demo data on app restart.
This status records preparation only; it does not book a shipment or mark the
order shipped/delivered. State updates require the current account to own items
in that order, and repeating the action leaves the order unchanged.


## Delivery login and regional pickup

The welcome/login page includes **Delivery login**, separate from resident and
administrator login. Delivery users sign in with a mobile number and PIN. Each
demo account has a fixed assigned region; logging in does not allow changing it.

| Region | Demo mobile number | Demo PIN |
|---|---|---|
| Rampura | 9000000001 | 2468 |
| Sundarpalli | 9000000002 | 2468 |
| Kothapet | 9000000003 | 2468 |
| Devipura | 9000000004 | 2468 |
| Mannargudi | 9000000005 | 2468 |

**Regional deliveries** lists products marked **Ready for shipping** whose
seller pickup region matches the delivery account. Region means the seller's
registered village, stored as `locationId` when posting a marketplace item or
book and snapshotted into the order. Buyer location does not determine pickup
coverage. Older entries with no region ID are excluded instead of guessing.
Unprepared products and products from other regions are not displayed.

Each product shows its order reference, quantity, seller, buyer and status,
with Contact Seller/Buyer actions to arrange the handover. Tap **Pick up** after
collection to change that product to **Picked up**, record the courier and time,
and disable repeat pickup. The **All**, **Awaiting pickup**, and **Picked up**
filters show available work and that courier's pickup history. Another seller's
products in the same order keep their own status. Sellers and buyers see pickup
updates in their existing order pages; sellers cannot reset picked-up items to
Ready for shipping. Delivery sign-out hides the queue immediately.

Flow: **Received → Ready for shipping → Picked up**. Ready for shipping is the
pickup queue entry point; this release does not claim the product was already
shipped or delivered. The separate resident Delivery request module remains
available for its existing pickup/drop requests.

To try: post and purchase an item in the same app session, sign in as its seller
and mark it Ready for shipping, sign out, then open Delivery login using the
account assigned to that seller's village. Pick it up and log back into the
seller/buyer account to see the updated status.

Implementation: `DeliveryAuthRepository`, `DeliverySession`,
`lib/features/delivery/`, and the regional queue/pickup checks in `CartState`.
Pickup rejects missing orders/items, missing delivery login, the wrong region,
and products not awaiting pickup. Credentials and data are demo-only. Production
requires authenticated delivery accounts, server-enforced region authorization,
atomic pickup assignment, persistent orders, and cross-device synchronization.
Current state survives account switches only within one running app session;
restarting the app clears orders, pickup history, and sessions.


## Delivery order maps and distances

In **Delivery login → Regional deliveries**, each product has **View map &
distances**. Its map displays **You** (blue), **Pickup** (orange), and **Delivery**
(purple). Opening an authorized order requests a foreground GPS fix; **Refresh
my location** obtains another fix. The page shows the measurement time and
reported accuracy. It does not run background tracking.

To supply exact addresses, sellers use **Set pickup location** when posting a
marketplace item or book, and buyers use **Set delivery location** in the cart
before checkout. The picker supports tapping a map, using current GPS, or
entering validated latitude/longitude, with an optional address/landmark. The
saved points are copied into the order and preserved through seller readiness,
pickup, account switches, and seller-specific order views. The cart's delivery
pin clears on checkout and account changes. Village region IDs continue to
control delivery access; coordinates do not change the assigned region.

The order map shows **You → pickup**, **You → delivery**, **Pickup → delivery**,
and the total of the two legs via pickup before collection. These are labelled
**straight-line estimates in kilometres**, not road distances or arrival times.
**Directions to pickup**, **Directions to delivery**, and **Directions via
pickup** open Google Maps for driving routes. Directions require a current GPS
fix and the relevant saved points; missing coordinates never fall back to a
village centre or fabricated address.

Location pins remain optional for legacy/contact-only demo flows. Orders without
pins clearly identify the missing pickup/delivery point and show unavailable
distances for those legs. Ask the seller/buyer for the address via the existing
contact actions. Denied/blocked permission, disabled location services, timeout,
and unavailable GPS show recovery guidance while saved pins remain usable. Map
tile failures retain coordinates/distances and offer **Retry map**. Order access
is rechecked against the current delivery account; signing out hides the map.

Implementation: `MapLocation`, `LocationService`, `MapLocationField`,
`LocationMap`, and `lib/features/delivery/delivery_order_map_screen.dart`.
[flutter_map](https://docs.fleaflet.dev/) displays OpenStreetMap tiles with visible
attribution and the app user agent, following the
[OpenStreetMap tile policy](https://operations.osmfoundation.org/policies/tiles/).
[geolocator](https://pub.dev/packages/geolocator) supplies foreground location;
[url_launcher](https://pub.dev/packages/url_launcher) opens
[Google Maps directions URLs](https://developers.google.com/maps/documentation/urls/get-started).
No map API key is required for this demo. Android declares internet and
coarse/fine location permissions; iOS includes a when-in-use purpose string.
Web geolocation needs HTTPS or localhost and browser permission. Tiles and
external directions need internet; distance calculations use saved coordinates
locally. Production needs persistent addresses, real-device permission/GPS
verification, and map-provider capacity appropriate for its traffic. Existing
in-memory demo storage and authentication limitations still apply.

### Admin territory maps

- Open **Territory map** from any admin dashboard level, or **Map view** from
  either directory. The map is scoped to the signed-in admin's subtree.
- Teal polygons show the current territory; purple polygons show its immediate
  subadmin territories. Tap a purple hierarchy pin or a **View by hierarchy**
  list entry to open that territory's map. Back returns to the parent map.
  This works from Main through State, District, Region, Area, and Branch.
- Blue person pins show users; orange shop/building pins show businesses and
  organisations. Toggle either layer and tap a record pin for its details.
  **View all users** and **View all businesses** open the current territory's
  directories, retaining the existing hierarchy browsing options.
- Boundaries and seeded coordinates in `lib/data/mock/mock_admin_map.dart` are
  explicitly labelled **demo** fixtures, not official geographic boundaries or
  verified addresses. Nested rectangles demonstrate the reporting hierarchy;
  they do not represent the actual shapes or coverage of the named territories.
- Branch **Add User** and **Add Organisation** forms offer an optional map
  location picker (map tap, GPS, or coordinate entry). Organisation registration
  from the resident flow also supports this field. Saved coordinates flow through
  the repositories into ancestor maps and are distinguished from demo pins.
  Records without coordinates are listed as **Location not set**, never placed
  at an inferred village centre. Registration remains possible without a pin.
- A location outside a demo polygon remains visible and included in map bounds;
  reporting assignment, not polygon containment, determines admin visibility.
- Map tiles require internet access. If tiles fail, retry is available and saved
  coordinates, overlays, and hierarchy lists remain accessible. OpenStreetMap
  attribution is displayed below the map.
- Production integration must replace the fixtures with approved territory
  polygon data and authorised saved coordinates, enforce subtree access on the
  backend, and persist locations (the current repositories are session-only).

### Registration API: Postman `auth/register-value`

The request reference is [`kanoct3.postman_collection.json`](./kanoct3.postman_collection.json),
folder **auth**, item **register-value**. The item name is not the route:
registration sends **POST `{{kan_auth_url}}/auth/register`**, with no authorization
header and a JSON body (`Content-Type: application/json`).

`lib/core/config/api_config.dart` centralizes `kan_auth_url`, defaulting to
`http://localhost:8084`. Override it at build/run time; the value is a base URL,
without `/auth/register`:

```bash
/home/kirancchand/Desktop/install/flutter/flutter_linux_3.29/flutter/bin/flutter run --dart-define=kan_auth_url=http://localhost:8084
```

For an Android emulator connecting to a service on the development computer, use
`--dart-define=kan_auth_url=http://10.0.2.2:8084`. On a physical device, configure
an address reachable from that device; localhost refers to the device itself.
Android debug builds permit HTTP for local development, and iOS permits local
network connections. Use HTTPS for deployed services. Flutter web also requires
the server to allow the app's origin through CORS; HTTPS pages cannot call an
HTTP auth server. Rebuild/restart when changing a `--dart-define`.

Resident registration and branch **Add User** share these fields:

| Form field | JSON field |
|---|---|
| Username (defaults to mobile when empty) | `username` |
| First, optional middle, and last name | `firstName`, `middleName`, `lastName` |
| Email, mobile, password | `email`, `mobno`, `password` |
| Date of birth (`DD/MM/YYYY`, valid date, not in the future) | `dateofbirth` |
| Gender dropdown | `gender: {value: number, label: string}` |
| Branch ID and name | `branch: {value: number, label: string}` |

Gender options load from the master API as described below. The branch default
remains editable: `2` / `ward name`, an example rather than a verified mapping. The village
picker (or signed-in admin's branch) still determines local directory scope and
WhatsApp-group assignment; it is not converted into a backend branch ID.
`status` and `usertype` are sent as `null`, matching the active Postman example.
The branch form's user-type selector is local metadata and is not sent as an API
admin role. Commented example fields such as `appId` are not sent.

The request has an eight-second timeout. Any non-2xx HTTP result, connection
failure, timeout, or invalid base URL falls back to the existing in-memory
registration and WhatsApp assignment. The UI explicitly identifies this as a
demo account. There is no automatic request retry, since a timed-out POST may
have succeeded on the server. Duplicate phones already registered or currently
being submitted locally are rejected before another API call.

The collection provides no response examples/schema. Therefore any HTTP 2xx
response counts as API acceptance; response IDs, tokens, and body-level success
flags are not inferred. Both successful API registration and the fallback create
a local session profile (`AppUser.apiRegistered` distinguishes the result).
Passwords are sent only in the request, are never stored in `AppUser`, and request
bodies/server responses are not logged. Login now follows the Postman `auth/login` item, as described below. Tokens
are held only in memory and are cleared on sign-out.
Repository calls without the new registration payload retain the old dummy path
for existing demo fixtures. New production forms always supply the API payload.


### Gender dropdown and shared `kan_url`

Both resident registration and branch **Add User** load gender choices using
`master/gender/getAllGender` from `kanoct3.postman_collection.json`:

- POST `{{kan_url}}/master/gender/getAll`, without authorization.
- JSON body: `{"requestName":"getAll_Gender"}`.
- Expected response: an array of `{value, label}` options, with numeric string IDs.
- On HTTP/network errors, an eight-second timeout, malformed/empty data, or
  duplicate IDs, use exactly `[{"value":"1","label":"Male"}]`.

The dropdown is disabled while loading and selects the first available option.
Users can change the selection when multiple options are returned. The selected
label is preserved; the ID is converted to a number in the registration payload
as required by the existing `auth/register-value` request. Manual gender ID and
label inputs have been removed. Registration's existing dummy-account fallback
remains separate from this lookup fallback.

`ApiConfig.kanUrl` defaults to `http://localhost:8070` and is shared through
`ApiConfig.kanUri(path)` and `KanMasterApi.postJson(path, body)` for other APIs
hosted at `kan_url`. Auth continues to use its separate `kan_auth_url` on port 8084.
Configure both using build-time values, for example with the Android emulator:

```bash
/home/kirancchand/Desktop/install/flutter/flutter_linux_3.29/flutter/bin/flutter run --dart-define=kan_url=http://10.0.2.2:8070 --dart-define=kan_auth_url=http://10.0.2.2:8084
```

For a local desktop/web server use `http://localhost:8070`; use a reachable host
address on physical devices. The same HTTP/CORS platform notes above apply.


### Login API and dummy testing fallback

The resident login screen follows **auth → login** in
`kanoct3.postman_collection.json`: POST `{{kan_auth_url}}/auth/login` with JSON
`{"username":"...","password":"..."}`. It uses the same configurable
`kan_auth_url` as registration (default `http://localhost:8084`). Usernames may
be text or mobile numbers; the form requires both a username and password.
Passwords are sent unchanged and are neither logged nor retained in profiles.

A successful response must be HTTP 2xx with a non-empty `access_token`.
`refresh_token` is retained when present, matching the collection's response
script. Tokens are available through `AuthRepository.tokens` for future API
integration, held in memory only, and cleared on sign-out or a new login attempt.
Authenticated master-data requests attach the current access token. Only a 401
triggers refresh and one retry; concurrent refreshes share one request. There is
no client-side expiry timer. Refresh uses POST `{{kan_auth_url}}/auth/refresh-accesstoken`
with `{"refresh_token":"..."}`. A rotated refresh token is retained when supplied.
Refresh failure clears API credentials and requires signing in again.
Token expiry is controlled by the auth backend.

As requested for testing, any HTTP rejection (including incorrect credentials),
network failure, eight-second timeout, or malformed/missing-token response opens
a **dummy login** without requiring prior registration. The app displays a
persistent **Demo login** banner with a sign-out action. This fallback has no API
tokens and does not grant admin or delivery authentication. It is intentional
testing behavior, not proof of backend authentication.

Existing session registrations can be found by their mobile number or registered
username and retain their village, name, and group. For an unknown username,
login creates a stable session-only profile using the username as its display
name and `loc_1` (Rampura) as its demo village. This profile is separate from the
registered-user directory and does not create a WhatsApp membership. The same
local profile projection is used after successful API login because the
collection only defines tokens, not a user-profile or village response schema.
Backend profile retrieval remains a separate integration task.

Repeated submissions while login is pending are blocked. Signing out during a
pending request cancels its local session result, preventing stale credentials
from restoring a signed-out session. Restarting the app clears profiles and tokens.

### Kerala State Admin geometry layer

Select **State Admin → Kerala** in the Admin Panel and open **Territory map**.
Kerala is also available as a child of Main Admin. Its boundary is loaded using
the Postman **master/state/getAllGeo** item:

- GET `{{kan_url}}/master/state/getAllGeo` (default `http://localhost:8070`).
- `Authorization: Bearer <access_token>` from the current successful API login.
- The `geometry` field supplies the map layer; only records named Kerala are rendered.

First sign in using backend credentials on the main login screen, then open the
Admin Panel and choose Kerala. The admin territory selector remains a local demo
selector; the backend must authorise the bearer token. Dummy login has no token
and cannot load this protected layer. HTTP 401/403, network errors, missing Kerala
data, and invalid geometry show an explanatory message with retry where applicable.
Kerala does not fall back to a fabricated rectangle.

The parser accepts a record array, a `data` array wrapper, or GeoJSON
FeatureCollection. State names can be supplied as `state`, `stateName`,
`state_name`, `name`, `label`, or feature properties (`state`, `STATE`, `ST_NM`,
`name`). `geometry` can be a GeoJSON object or JSON string containing Polygon,
MultiPolygon, Feature, FeatureCollection, or GeometryCollection. Polygon holes
and separate polygon parts are retained. GeoJSON longitude/latitude pairs are
converted to map latitude/longitude and the camera fits the returned layer.
The collection has no response example; these supported shapes are covered by
fixtures. A live unauthenticated check returned 401, so a real authenticated
response still needs verification with your backend account.

### Kerala District Admin geometry layer

Select **District Admin → Kerala districts** and open **Territory map**. The
district map uses the Postman **master/district/getAllGeo** item:

- GET `{{kan_url}}/master/district/getAllGeo` (default `http://localhost:8070`).
- `Authorization: Bearer <access_token>` from the successful API login.
- Records are filtered to Kerala and each district's `geometry` is rendered as
  a separately labelled indigo polygon layer. Polygon, MultiPolygon, feature
  collection, JSON-string geometry, and holes are supported.

The response has no Postman example schema, so district and state names are
accepted from common fields (`district`, `districtName`, `district_name`,
`name`, `label`, and their `properties` equivalents). Missing or invalid data,
401/403 responses, and network failures show a retryable error; no fabricated
district boundaries are used. Demo login cannot access this protected layer.

### Kerala State Admin district subadmins

When **State Admin → Kerala** is opened, the dashboard loads its subadmin list
from the Postman **master/district/getByState** item before showing district
children:

- GET `{{kan_url}}/master/district/getByState/1`.
- `Authorization: Bearer <access_token>` from the successful API login.
- The `1` is the Kerala state ID used by this app and can be changed
  in `AdminRepository.loadDistrictsForState` when the backend mapping is supplied.

The response may be a list or a `data`/`result` wrapper. District IDs and names
are accepted from `value`/`label`, `id`/`name`, or `districtId`/`districtName`.
Each result becomes a scoped District Admin child, so selecting it preserves
the existing hierarchy breadcrumbs, directories, and district geometry map.
The list has a loading indicator and retryable error card. A missing API token
does not invent district children; demo login therefore cannot populate this
protected list. Repeated loads replace the prior API results so stale districts
do not remain visible.

Kerala currently has no configured local district/branch records or directory
pins. Its state geometry does not create subadmins, users, or organisations;
existing scoped directory and map navigation remain available. Other territories
retain their explicitly labelled demo boundaries. Tokens are never stored in
map data, URLs, or logs; clearing the login session removes the protected layer.

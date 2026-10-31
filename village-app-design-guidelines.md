# Village Community App — UI/Design Guidelines

This document defines the visual design system for the Flutter app so every screen looks consistent, modern, and polished — instead of relying on default Flutter widget styling.

---

## 1. Design Principles
- **Consistency over creativity** — reuse the same spacing, colors, and components everywhere instead of styling each screen separately
- **Clarity first** — village users may include non-tech-savvy people; keep layouts simple, buttons big, text legible
- **Local, warm, trustworthy feel** — this is a community app, not a corporate one; use friendly rounded shapes, warm accent colors, real photos over generic icons where possible
- **Familiar patterns** — model layouts after apps users already know (Swiggy/Zomato-style category grids, Urban Company-style service cards) so navigation feels intuitive

---

## 2. Color System

Use **Material 3** with a generated color scheme from a single brand/seed color.

| Role | Purpose | Example |
|---|---|---|
| Primary | Main brand color — buttons, active states, highlights | Warm green / village-themed color |
| Secondary | Supporting accents — tags, secondary buttons | Complementary muted tone |
| Surface | Card and container backgrounds | Off-white / light neutral |
| Background | Screen background | White / very light gray |
| Error | Errors, destructive actions | Red |
| Success | Confirmations, completed transactions | Green |
| On-Primary / On-Surface | Text/icons placed on colored backgrounds | White / dark gray |

**How to generate:** Pick one brand color → paste into [Material Theme Builder](https://m3.material.io/theme-builder#/custom) → export a full light/dark `ColorScheme` for Flutter.

**Dark mode:** Support it from day one using `ColorScheme.fromSeed(brightness: Brightness.dark)` — avoids extra rework later.

---

## 3. Typography

Avoid the default system font — it's the #1 reason apps look unfinished.

- **Package:** `google_fonts`
- **Suggested fonts:** Poppins, Inter, or Manrope (clean, modern, good readability at small sizes)

| Style | Size | Weight | Usage |
|---|---|---|---|
| Display | 28–32 | Bold | Splash/onboarding headlines |
| Headline | 22–24 | SemiBold | Screen titles (e.g. "Buy & Sell") |
| Title | 18 | SemiBold | Card titles, section headers |
| Body | 14–16 | Regular | Main content, descriptions |
| Caption | 12 | Regular/Medium | Timestamps, labels, hints |

Define these once in a `TextTheme` and reuse via `Theme.of(context).textTheme.titleLarge` etc. — never hardcode font sizes in individual widgets.

---

## 4. Spacing & Layout

Use a fixed spacing scale instead of random padding values:

```
4  → micro spacing (icon-to-text gap)
8  → tight spacing
16 → standard padding (default screen margin, card padding)
24 → section spacing
32 → large section breaks
```

- Screen horizontal padding: **16px** standard
- Card internal padding: **16px**
- Gap between cards in a list/grid: **12–16px**
- Consistent corner radius: **12–16px** for cards, **8px** for buttons/chips, **24px+** for pill-shaped buttons

---

## 5. Core Components

### Buttons
- Primary action: filled button, brand color, rounded corners, bold label
- Secondary action: outlined button
- Avoid plain default `TextButton`/`ElevatedButton` styling — customize via theme

### Cards (used heavily: listings, services, shops)
- Rounded corners (12–16px)
- Soft elevation/shadow (avoid harsh default Material shadows)
- Image on top or left, title + short description, price/tag, CTA button/icon

### Service Grid (Home Page)
- Icon + label grid (2–4 columns), similar to Swiggy's category row
- Each service icon in a colored rounded container, consistent icon style (use a single icon pack — e.g., `phosphor_flutter` or `lucide_icons` — never mix icon families)

### Lists (Marketplace items, books, plants, etc.)
- Card-based list or grid view with image, title, price, location/tag
- Use `shimmer` package for loading skeletons instead of plain spinners

### Emergency Contacts / Directory
- Simple list tiles with icon, name, tappable phone number (click-to-call), category tag

### Top Bar
- **Component:** `lib/core/widgets/village_top_bar.dart`, shared by Home, Services, and Profile.
- Display **Village Connect** in the primary brand color, with a secondary line showing the page name or Home greeting and village.
- Provide **Notifications** (bell) and **Cart** actions using the existing Phosphor icon family, tooltips, and minimum 48 × 48 touch targets.
- Use an 88px toolbar, theme-aware colors, a subtle bottom divider, and ellipsis for long titles. The standard AppBar handles the system status-bar inset.
- Notifications opens `NotificationsScreen`, currently an empty inbox. No notification backend or unread count is implemented.
- Cart opens `CartScreen`, with quantity controls, removal, totals and demo checkout, or an empty state with **Browse local listings**. See Shared cart and item purchases below.
- Do not display fabricated badges or counts. Admin retains its separate administration header; detail pages retain titles and back buttons.

### Bottom Navigation
- **Reference:** `bottom.gif` — a raised circular active tab travels along a curved cutout in the navigation surface.
- **Implementation:** `lib/core/widgets/village_bottom_bar.dart`, used by `lib/features/root_shell.dart`.
- Preserve the four existing destinations: **Home, Services, Profile, Admin**. The existing `IndexedStack` retains each screen's state when switching tabs.
- The active button uses the app's emerald-to-teal gradient and a white filled Phosphor icon. Inactive tabs use muted outline icons; all tabs have visible labels.
- Animate the button and its matching cutout together over **280 ms** with an ease-in-out curve. Respect the device's reduced-motion setting by switching instantly.
- Use theme-aware surface, border, and label colors for light and dark mode. Reserve space for the system bottom inset and enlarged text; the bar does not cover screen content.
- Each tab provides a full-cell tap target, keyboard focus, tooltip, and selected-state semantics. Position the indicator correctly in right-to-left layouts.
- The GIF is a visual reference only; no extra runtime asset or dependency is required.

### Images
- Use `cached_network_image` for smooth loading + placeholder/error states
- Consistent aspect ratios per component (e.g., 1:1 for product thumbnails, 16:9 for banners)

---

## 6. Motion & Feedback
- **Package:** `flutter_animate` for subtle fade-in/slide-in on screen load and list items
- Button press: slight scale/opacity feedback (built into Material by default — don't remove it)
- Page transitions: use consistent transition style app-wide (avoid mixing default push with custom ones randomly)
- Keep animations short (150–300ms) — this is a utility app, not a showcase; motion should feel snappy, not decorative

---

## 7. Recommended Packages

| Package | Purpose |
|---|---|
| `google_fonts` | Custom typography |
| `flutter_animate` | Micro-animations, transitions |
| `shimmer` | Loading skeletons |
| `cached_network_image` | Image loading with caching/placeholders |
| `phosphor_flutter` or `lucide_icons` | Consistent icon set |
| `flutter_svg` | Crisp vector icons/illustrations |
| `google_fonts` + Material 3 `ColorScheme.fromSeed` | Theme generation |

---

## 8. Design Workflow (Recommended)
1. **Pick one brand seed color** that represents the village/community feel
2. **Generate the Material 3 theme** using Material Theme Builder
3. **Design 3 key screens in Figma first** — Home, a Service Listing screen, Profile — before writing more UI code
4. **Build a shared `AppTheme` file** in Flutter (colors, text styles, button styles, card decoration) and apply it globally via `ThemeData`
5. **Rebuild existing screens** using the shared theme + components instead of one-off styling
6. **Reference inspiration** from [Mobbin](https://mobbin.com) or [Dribbble](https://dribbble.com) for local-marketplace/service-app UI patterns

---

## 9. Quick Before/After Checklist
- [ ] Replaced default system font with Google Fonts
- [ ] Applied Material 3 theme with a single seed color (light + dark mode)
- [ ] Standardized spacing (4/8/16/24/32 scale)
- [ ] Standardized corner radius across cards/buttons
- [ ] One consistent icon family used app-wide
- [ ] Cards have proper elevation/shadow (not flat, not harsh)
- [ ] Loading states use shimmer, not blank screens/spinners only
- [ ] Images use caching + placeholders
- [ ] Bottom navigation limited to key sections with active/inactive icon states
- [ ] Text hierarchy applied (headline/title/body/caption) instead of uniform text sizes


## Ride Pool glassmorphic reference theme

Ride Pool follows `samples/ride pool.jpg`: an indigo glass search panel, lavender/blue/peach gradient backgrounds, frosted ride cards, and orange primary actions. `RidePoolGlass` uses clipped 14px backdrop blur, translucent light or deep-indigo fills, highlight borders, and soft shadows. A shared `BackdropGroup` sits above the gradient and radial glows. Apply glass to the route search panel, filters/sorting, ride cards, detail sections, offer form and bottom action bars. Keep text opaque and readable. The browse screen uses a route search panel, All / Car / Bike filters, Earliest / Cheapest sorting, and route cards with vehicle type, seats, departure, driver, and per-seat pricing. Offer a Ride and the detail screen’s Contact Driver action stay accessible at the bottom in glass action bars. Detail and offer screens use the same local palette via `ride_pool_theme.dart`; dark mode uses deep indigo surfaces and readable lighter text. Keep the existing Phosphor icons and typography. Search, filtering, sorting, offering rides, and contacting drivers remain functional; the reference's airline brands, airport content, and unrelated travel modes are not app features.


## Plants glassmorphic reference theme

Plants follows `samples/plant1.jpg` and `samples/plant2.jpg`: cream/mint/sage gradient backgrounds, forest-green actions, rounded botanical hero panels, a plant-card grid, and a large plant detail illustration. Use `PlantsGlass` for the hero, search, listing cards, detail panels, posting form and bottom actions: clipped 14px backdrop blur, translucent cream or deep-green fills, fine highlight borders, and soft shadows. `PlantsTheme` provides a shared `BackdropGroup` over soft leaf-coloured radial glows, plus matching inputs, chips, contact sheets and readable opaque text. The browse page includes live title/category search and category chips generated from repository listings. Cards show real listing titles, prices, categories, availability, and locations. The detail page shows the seller's description and contact action. Listing a plant reuses the marketplace form inside the Plants theme through its optional `formWrapper`. The local theme supports dark mode. Narrow screens and enlarged text use one-column cards; artwork scales to its available width.

`lib/features/services/plants/` owns the presentation; `MarketplaceRepository` remains the data layer. Botanical artwork is drawn in Flutter and is illustrative, not a seller photo or a species identification. Detail pages label it accordingly. Do not invent ratings, care measurements, AI diagnosis or scanning from the visual references. Item purchases use the shared demo cart described below.


## Cake Marketplace glassmorphic reference theme

Use `samples/cake.jpg` as the visual reference for Cake Marketplace. Translate its playful dessert storefront into cake listings: cream backgrounds (`#FFFAF2`), blush surfaces (`#FFE2E7`), raspberry actions (`#B72F59`), pink/peach background gradients, rounded cards, and large cake artwork. Add frosted glass with `CakeGlass`: clipped 14px backdrop blur, translucent cream or deep-rose fills, bright fine borders, and soft raspberry shadows. Shared grouped filters sit over pink/peach radial glows; keep text opaque and readable. Apply glass to the hero, search, dessert cards, detail sections, listing form and bottom actions. Preserve the app's typography and Phosphor icons. The feature-local `CakeTheme` supplies matching inputs, chips, buttons, contact sheets, and dark-mode surfaces.

The browse screen includes a featured available cake, live search across titles/categories/bakers, category filters from repository data, a responsive product grid, and a persistent **List a cake** action. Detail pages show the listing price, description, availability, bakery, location, and **Contact Baker** action. The posting form reuses `MarketplacePostScreen` with `CakeGlass.form` under the same theme and refreshes the catalog on success. Dark mode uses deep rose glass with pale raspberry accents; enlarged text and narrow screens retain the responsive grid. Both direct service routing and shared marketplace entry points open these dedicated screens.

Cake artwork is illustrative Flutter drawing, with chocolate and vanilla treatments; it is not seller photography. Label it on details. Use actual listing information. The reference's discounts, ratings, size/extras pricing, real payment, and delivery tracking are not implemented by this styling change and must not appear as working features.


## Online Library glass theme

Use `samples/book.jpg` as the reference: pale aqua backdrops, cyan accents, pastel book covers, horizontal book shelves, and a compact community collection. Add glassmorphism through clipped 14px backdrop blur, translucent light/dark surfaces, fine highlight borders, and soft shadows over aqua, blush and lavender gradients. `library_theme.dart` contains `LibraryPage` and `LibraryGlass`; grouped backdrop filters share work across non-overlapping glass panels. Keep text opaque and readable in both light and dark modes.

Browse books with live title/author/genre search and All / For Rent / Wanted (Buy) / For Sale filters. The fresh shelf uses newest repository listings; the community collection shows listing type and rent, sale price, or buyer budget. Book details and the posting form share the glass treatment. The bottom action stays accessible. Wanted listings contact the buyer; rentals contact the owner to arrange rental.

Pastel covers are original typographic demo artwork derived from listing metadata, not official book jackets. The UI does not claim popularity, ratings, reading history, social followers, or reading-time statistics from the reference. Book data, posting, and contact actions continue through the existing repository and mock contact flow.


## Pharmacy glassmorphic reference theme

The Medicine service is renamed **Pharmacy**, represented by `ServiceType.pharmacy`. Use `samples/medicine.jpg` and `samples/pharmacy.jpg` for its mint/cyan backgrounds, teal accents, navy text, product imagery, category navigation and local pharmacy cards. `PharmacyTheme` supplies light/dark palettes and background glows. `PharmacyGlass` uses rounded clipping, grouped 14px backdrop blur, translucent light or deep-teal fills, fine white borders and soft shadows. Apply it to the hero, search, product cards, detail panels, posting form and bottom actions. Keep text opaque; narrow screens and enlarged text use one-column products.

The catalog searches listing titles, categories and seller names; category filters come from repository data. Local pharmacy contacts are deduplicated from catalog sellers and show their stated location. Details show the existing listing description, price, category and availability, with **Contact Pharmacy** opening the current mock contact sheet. Posting reuses `MarketplacePostScreen` through its optional form wrapper and refreshes the catalog. Product artwork is generic illustration, not verified packaging.

Use actual listing data. Do not infer distances, ratings, expiry dates, clinical benefits, professional verification or delivery guarantees from the references. Prescription upload, real payments and clinical services in the references remain future features.


## Home latest-entry slider

Place **Latest across services** between the home hero and service grid. Show exactly one card per service in stable service order, selected by creation timestamp. Use rounded cards with the service's semantic tint/icon, latest title, concise price/status/owner summary, relative time, and a View action. Retain a partial next card as a swipe cue; include previous/next controls with tooltips and a page counter. Increase card height for enlarged text and support light/dark themes. Use animated pill/dot page indicators matching `AdCarousel`. Automatically advance every five seconds and wrap from the last card to the first; restart the interval after manual navigation. Skip advancement while scrolling, while another route is open, while the app is inactive, or when reduced motion is requested.

Keep empty modules visible with Explore, and failed modules with Retry. Load services independently so one error does not remove other cards. Newly created entries notify the slider; home pull-to-refresh and section Refresh reload it. Ride recency uses its posting timestamp, separate from departure. Marketplace/library/ride cards open the respective detail page, while video/delivery cards open their module list. Preserve each repository's current visibility and display review/delivery status.


## Buy & Sell glassmorphic reference theme

Use `samples/buysell.jpg` as the reference: icy blue backgrounds, cobalt actions (`#2453D4`), rounded product tiles, compact search/category controls, and a blue gradient banner with a warm yellow selling action. `lib/features/services/buy_sell/` owns the local theme, catalog, detail screens and category illustrations. `BuySellGlass` uses clipped 14px backdrop blur, translucent light or deep-blue fills, fine highlight borders and soft blue shadows over blue/lavender gradients. Group non-overlapping backdrop filters and keep text opaque. Apply the glass treatment to search, product cards, details, the posting form and persistent bottom actions.

Search listing titles, categories and sellers; derive category filters from repository data. Use a responsive two-column product grid, switching to one column on narrow screens or with enlarged text, and three on wider screens. Cards show category, condition, seller, price and sold-out status. Details retain description, availability, location, posting time and Contact Seller. Sell an item reuses `MarketplacePostScreen` with `BuySellGlass.form`, refreshing the catalog on success. Shared marketplace routes and home latest-entry links reach the same themed details. Support both light and dark modes.

The reference guides presentation; discounts, stock counts, ratings and favourites are not implemented features. Checkout uses the shared demo cart described below. Product illustrations use the listing's category icon and are labelled as illustrations on details; they are not seller photographs. Keep the existing repository and mock contact behavior.


## Images and videos on every service entry form

All eight services support image/video attachments: Buy & Sell, Plants, Cake and Pharmacy use `MarketplacePostScreen`; Online Library uses `PostBookScreen`; Ride Pool uses `PostRideScreen`; Village YouTube uses `SubmitVideoScreen`; Delivery uses `RequestDeliveryScreen`.

Use the shared `MediaAttachmentField` within each module's existing themed form. Provide **Add image** and **Add video** file-selection actions, image thumbnails with an expandable preview, video filenames and sizes, and individually labelled removal controls. Wrap the actions on narrow screens and preserve light/dark contrast. Disable selection/removal during submission and submission while a file is being read. Cancellation keeps the existing selection; show readable inline errors for unsupported, empty, oversized or unreadable files.

Allow up to five attachments, 20 MB per file and 50 MB total per entry. Supported image extensions are JPG/JPEG, PNG, WebP and GIF; videos are MP4, MOV and WebM. Check extension and byte length before reading, and bound the streamed read. The native picker is provided by Flutter's `file_selector`; it selects existing files rather than recording camera media. Platform type filters are hints; this is not server-side content validation.

Pass attachments through all five repositories into their models as immutable list snapshots. Show saved attachments on marketplace, book and ride details, and on Village YouTube/delivery entry cards. Images and videos use the shared gallery and full-screen viewer; uploaded catalog covers take priority over illustrative fallback art. Village YouTube requires either an attached video or a valid HTTP(S) video link, retains that link with the submission, and keeps the pending-review status. Other modules' attachments are optional.

**Current storage:** files and entries are retained only in memory for the current mock-app session. No server upload, persistent media storage, cross-device sharing, video transcoding or publishing is performed. A production upload/storage API and server-side validation are still required. The new selection controls must not show a fabricated upload-success status.


## Multi-image and video galleries

Every service supports viewing all submitted attachments in their original order. Use the shared `MediaGallery` on Buy & Sell, Plants, Cake, Pharmacy, Library and Ride Pool detail pages, and in Village YouTube and Delivery entry cards. Show a swipeable media area, current/total count, image/video totals, labelled previous/next controls, selectable thumbnails, filenames and a full-screen action. Hide the gallery for entries without attachments. Catalog `MediaCover` widgets show the first uploaded image or a video tile with an attachment-count badge, opening the complete gallery; retain illustrative artwork for entries without attachments.

The full-screen viewer supports image pan/zoom and uploaded-video playback with play/pause, scrubbing, elapsed/duration time and mute controls. Only the active video creates a player. Do not autoplay; stop and dispose playback when changing items or leaving the viewer, and pause when the app becomes inactive. File selection previews open the same viewer. Display a readable failure state for corrupt images, unavailable video playback or unsupported codecs, with retry for video initialization failures. Preserve narrow-screen layouts, enlarged text, light/dark themes and accessible control labels.

`video_player` handles Android/iOS/web playback. Native attachment bytes are written to a uniquely named temporary directory and removed after the player is disposed; web playback uses a local data URI without a server request. iOS deployment requires 13.0 or later; the configured Flutter SDK supplies Android API 24 as its minimum. Codec support varies by device/browser, and Windows/Linux playback has no implementation in the selected plugin. Platform playback failures use the same fallback UI. External YouTube/Drive links remain saved text, not embedded players.

Storage remains session-only mock storage. This gallery does not add cloud uploads, persistent media URLs, cross-device sharing or transcoding. Validate actual codec playback on target devices in addition to widget tests.


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

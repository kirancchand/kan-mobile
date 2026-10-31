# Flutter App — Visual Design System Migration

## Objective

The existing Flutter mobile application is already implemented and functional.

DO NOT rebuild the application from scratch.

DO NOT change business logic, API integrations, database logic, navigation logic, authentication, state management, or existing functionality unless required to support the new visual design system.

Your task is to upgrade the application's visual design to a polished, modern, attractive, premium community-app experience using the design system below.

The existing functionality must remain intact.

---

# 1. New Visual Theme

Use this as the application's primary visual identity.

## Primary Colors

Primary Emerald:
#00A878

Secondary Teal:
#00B8A9

Accent Sunshine:
#FFC857

Accent Lime:
#B8E04B

Primary Text / Midnight:
#102A2A

Main Background / Cloud:
#F7FAF8

Secondary Background / Mist:
#E8F2EF

Surface / White:
#FFFFFF

Error / Coral:
#FF6B5E

Success:
#00A878

---

# 2. Color Usage

Do NOT use all colors equally.

Recommended visual balance:

60% — Cloud / White
25% — Emerald / Teal
10% — Midnight text
5% — Sunshine / Lime / Coral accents

The application should feel colorful and attractive without becoming childish.

Emerald should be the primary brand color.

Teal should be used for secondary interactive elements.

Sunshine should be reserved for important highlights, events, announcements and special information.

Lime should be used sparingly for secondary visual emphasis.

Coral should primarily communicate errors, warnings or attention.

---

# 3. Design Character

The application should feel:

* Modern
* Friendly
* Premium
* Welcoming
* Community-oriented
* Fresh
* Trustworthy
* Easy to use
* Attractive to younger users
* Comfortable for older users

The application must NOT look like:

* A generic Flutter application
* A government portal
* An old-fashioned village website
* A corporate admin dashboard
* A children's application
* A template generated from Material widgets

---

# 4. Preserve Existing Application

Before changing code:

1. Inspect the complete existing Flutter project.
2. Identify the current theme system.
3. Identify duplicated colors and typography.
4. Identify reusable components.
5. Identify screens and navigation.
6. Identify existing state management.
7. Identify existing API/data layers.
8. Identify existing localization.
9. Identify existing dark/light theme support.

Do not make destructive changes.

Preserve all existing functionality.

---

# 5. Create a Central Design System

Do not hard-code colors throughout individual screens.

Create or improve a centralized design system.

For example:

lib/core/theme/
app_colors.dart
app_theme.dart
app_typography.dart
app_spacing.dart
app_radius.dart
app_shadows.dart

Adapt the structure to the existing project architecture rather than blindly creating these exact files.

All screens should consume the centralized design tokens.

---

# 6. Typography

Use a modern, highly readable font.

Prefer:

Inter

or an existing project font if it is already appropriate.

Create a consistent hierarchy:

Display
32–36px

H1
28–32px

H2
22–26px

H3
18–20px

Body
15–17px

Secondary
13–14px

Caption
11–12px

Use font weight and size to create hierarchy.

Avoid excessive bold text.

---

# 7. Spacing

Use a consistent 8-point spacing system.

Preferred values:

4
8
12
16
24
32
40
48
64

Do not introduce random spacing values unless there is a strong layout reason.

---

# 8. Border Radius

Use modern but controlled corner radii.

Suggested:

Small:
8px

Medium:
12px

Large:
16px

Prominent surfaces:
20px

Do not make every component excessively rounded.

Avoid making the entire application look like a collection of pills.

---

# 9. Cards

Do not put everything inside cards.

Use cards only when they improve grouping or hierarchy.

Preferred card style:

Background:
#FFFFFF

Border:
#E8F2EF

Subtle elevation/shadow

Radius:
12–16px

Avoid heavy shadows.

Avoid excessive floating cards.

---

# 10. Buttons

Primary button:

Background:
#00A878

Text:
#FFFFFF

Secondary button:

Background:
#E8F2EF

Text:
#102A2A

Accent button where appropriate:

Background:
#FFC857

Text:
#102A2A

Buttons must include appropriate:

* Default state
* Pressed state
* Disabled state
* Loading state

Maintain comfortable touch targets.

---

# 11. Navigation

If the application already uses bottom navigation, preserve the existing navigation structure unless there is a strong UX reason to change it.

Selected:

#00A878

Unselected:

#66756B or an equivalent muted neutral

Navigation background:

#FFFFFF

Keep navigation visually clean.

Do not introduce unnecessary navigation elements.

---

# 12. Home Screen

The home screen should prioritize:

1. User context
2. Important announcements
3. Primary actions
4. Community information
5. Services
6. Recent/relevant activity

Use visual hierarchy rather than making every section equally prominent.

Use Emerald for primary actions.

Use Sunshine for special announcements/events.

Use Teal for secondary services.

---

# 13. Icons

Use one consistent icon family throughout the application.

Do not mix unrelated icon styles.

Icons should be:

* Simple
* Modern
* Recognizable
* Accessible

Use icons together with labels when the meaning may not be obvious.

---

# 14. Images and Illustrations

If the existing application uses images or illustrations:

* Preserve useful existing assets.
* Improve presentation where necessary.
* Use rounded image containers where appropriate.
* Avoid decorative images that don't provide value.

Do not add random stock imagery merely to fill empty space.

---

# 15. Empty States

Improve all empty states.

Each empty state should communicate:

1. What is empty
2. Why it matters
3. What the user can do next

Include a clear CTA where appropriate.

---

# 16. Loading States

Replace unnecessary full-screen generic spinners with:

* Skeleton loading
* Progressive loading
* Contextual loading indicators

Use the new visual system for loading components.

---

# 17. Error States

Errors must be visually consistent.

Use Coral:

#FF6B5E

for error/attention states.

Do not expose technical exceptions to users.

Provide clear recovery actions where possible.

---

# 18. Accessibility

The visual redesign must remain accessible.

Ensure:

* Strong text contrast
* Large touch targets
* Readable typography
* Clear focus/pressed states
* Semantic labels
* Color is never the only way to communicate information

Do not sacrifice accessibility for visual appearance.

---

# 19. Dark Mode

If dark mode already exists, redesign it intentionally using the new palette.

Do not simply invert colors.

Suggested dark foundation:

Background:
#081414

Surface:
#102A2A

Primary:
#00B894

Secondary:
#20C7B7

Accent:
#FFC857

Text:
#F5FAF8

Secondary text:
#A8BCB6

Maintain readable contrast.

---

# 20. Existing Screens

Apply the design system consistently to every existing screen.

Do not redesign only the home screen.

Review:

* Splash
* Onboarding
* Authentication
* Home
* Dashboard
* Lists
* Details
* Forms
* Search
* Notifications
* Profile
* Settings
* Dialogs
* Bottom sheets
* Empty states
* Error states
* Loading states

Only modify screens that exist in the current application.

Do not invent unnecessary screens.

---

# 21. Important Rule: Do Not Overdesign

The objective is NOT to add more visual elements.

Improve the existing application through:

* Better hierarchy
* Better typography
* Better spacing
* Better color
* Better component consistency
* Better interaction states
* Better accessibility

Prefer simplicity.

---

# 22. Implementation Process

Follow this order:

### Step 1

Analyze the existing project.

### Step 2

Identify the current design system and duplicated styling.

### Step 3

Create/update centralized design tokens.

### Step 4

Update global Flutter ThemeData.

### Step 5

Update shared components.

### Step 6

Update screens using the shared components.

### Step 7

Review light mode.

### Step 8

Review dark mode.

### Step 9

Review responsive behavior.

### Step 10

Run Flutter analyzer and tests.

### Step 11

Fix visual inconsistencies.

---

# 23. Quality Gate

Before declaring the work complete, inspect the application as a professional UI/UX designer.

Verify:

* Every screen uses the same visual language.
* Colors come from centralized theme tokens.
* Typography is consistent.
* Spacing is consistent.
* Buttons are consistent.
* Cards are consistent.
* Navigation is consistent.
* Empty states are designed.
* Loading states are designed.
* Error states are designed.
* Light mode works.
* Dark mode works.
* Accessibility remains acceptable.
* Existing functionality still works.

The final result should feel like a single professionally designed product rather than individually styled Flutter screens.

---

# 24. Critical Constraint

DO NOT change:

* Business rules
* API contracts
* Database behavior
* Authentication behavior
* Existing data models
* Existing state-management architecture
* Navigation behavior

unless absolutely necessary for the UI migration.

If a visual improvement can be achieved without changing functionality, choose that approach.

Before making large architectural changes, explain why they are necessary.

---

# Final Objective

Transform the existing application from its current visual appearance into a:

**Modern + Premium + Friendly + Vibrant + Accessible Community App**

using the:

**Emerald + Teal + Sunshine**

design system.

The redesign must feel intentional, cohesive and production-ready.



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

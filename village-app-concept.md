# Village Community Mobile App — Concept Document

## Overview
A mobile application extending our existing web application and admin dashboard, designed to serve as a central digital hub for our village community. The app will connect residents, local shops, organizations, and services all in one place.

**Development approach:** Build the mobile app first using mock/dummy data. Once the app is complete and validated, integrate it with the real backend (the existing web app/admin dashboard infrastructure).

---

## 1. Home Page

The landing screen of the app, giving users a quick overview of everything happening in the village and access to all services.

**Home page includes:**
- **Advertisements** — Major/featured ads (banners, carousels, sponsored listings)
- **Village Events & Updates** — News feed of upcoming events, announcements, and updates
- **Latest Across Services** — A home slider with the most recently posted entry from each module; swipe or use previous/next controls, and tap to open the entry or its module. Automatically rotate every five seconds with looping and animated page indicators, respecting reduced motion; refresh after new posts.
- **Services Directory** — Quick access to all services offered through the app (see Section 2)
- **Emergency Contacts** — Village emergency numbers (police, hospital, fire, ambulance, panchayat/local authority, etc.)
- **Shops & Organizations Directory** — List of registered local shops and organizations with their contact details (name, category, phone number, address, maybe timings)

---

## 2. Services

The app will offer a suite of mini-services (modules), each functioning like its own marketplace within the app. Architecture should support adding new services easily in the future.

| # | Service | Description |
|---|---------|-------------|
| 1 | **Buy & Sell Items** | General marketplace for villagers to list and purchase used/new items |
| 2 | **Online Library** | Peer-to-peer book rental, buying, and selling with an aqua glassmorphic bookshelf inspired by `samples/book.jpg`, search, and listing-type filters |
| 3 | **Plants App** | Marketplace for buying and selling plants, with mint glassmorphic screens inspired by `samples/plant1.jpg` and `samples/plant2.jpg` |
| 4 | **Ride Pool** | One ride-sharing service for cars and bikes/two-wheelers, with an indigo/lavender glassmorphic UI inspired by `samples/ride pool.jpg`. Users choose Car or Bike when offering a ride and can browse all rides or filter by vehicle type. |
| 5 | **Pharmacy** | Medicines and health essentials from local pharmacies, with a teal glassmorphic catalog inspired by `samples/medicine.jpg` and `samples/pharmacy.jpg` |
| 6 | **YouTube Channel Integration** | Village's own YouTube channel; users can submit their videos to be featured/shared on the official channel |
| 7 | **Cake App** | Marketplace for buying and selling cakes (home bakers, local bakeries), with a cream-and-raspberry glassmorphic storefront inspired by `samples/cake.jpg`, flavour search/filtering, and baker contact |
| 8 | **Delivery App** | Local delivery service for getting products delivered within the village |
| 9 | **Future Services** | Architecture should be modular/scalable to allow new services to be added over time |

---

## 3. Technical Approach

**Platform: Flutter** (single codebase for Android & iOS)

### Phase 1 — Mobile App (Frontend-first)
- Build the complete mobile app UI/UX for all modules listed above
- Use **mock data** (static JSON / local dummy data) to simulate:
  - Home page ads, events, shop/org listings, emergency contacts
  - Each service's listings (items, books, plants, rides, medicines, cakes, delivery orders, videos)
  - Location database, WhatsApp group assignment logic, and admin analytics (see Sections 4 & 5)
- Focus on navigation flow, screen design, and core user interactions (browse, post/list, buy/sell/request)

### Phase 2 — Backend Integration
- Once the app is functionally complete and tested with mock data
- Connect to the existing backend used by the web application & admin dashboard
- Replace mock data layer with real API calls
- Sync mobile app with admin dashboard (for managing ads, events, shop registrations, service listings, etc.)

---

## 4. Location-Based Registration & WhatsApp Group Assignment

### Location Database
- Maintain a **location database** (list of villages/areas the app serves)
- During **user registration**, the user selects/picks their location from this database

### WhatsApp Group Auto-Assignment Logic
When a user registers under a location, the app checks whether a service (WhatsApp group) already exists for that location:

1. **Service not yet started in that location** → Automatically create a new WhatsApp group for that location, and add the user to it
2. **Service already exists (group already created)** → Add the user to the existing group
3. **Group is full (exceeds member limit, e.g. WhatsApp's 1024-member cap or a custom threshold)** → Automatically create a **second group** for that same location and start adding new users to it
4. This continues indefinitely — Group 1 → Group 2 → Group 3 ... as each fills up, for every location

**Notes / things to finalize:**
- Requires WhatsApp Business API (or a similar integration) to programmatically create groups and add members — this is not possible with the standard consumer WhatsApp app
- Need to decide the max-member threshold per group before a new one is spun up
- Need a mapping table: `Location → [Group 1, Group 2, Group 3, ...]` with member counts tracked
- Consider fallback/notification if group creation fails (e.g., add user to a temporary holding group)

---

## 5. Admin Panel & Location Hierarchy

### Location Admin
- Each **location** has its own **Admin login**
- A location admin can view, for their assigned location only:
  - Businesses/people currently registered in that location
  - Transactions happening in that location
  - Other location-level analytics (active users, service usage, group member counts, etc.)

### Head Admin (Hierarchy)
- Multiple location admins report up to a **Head Admin**
- The Head Admin can view **consolidated analytics across all locations** (i.e., oversight over all location admins and their respective data)

### Suggested Role Hierarchy
```
Head Admin (Super Admin)
   │  — Views analytics across ALL locations
   │  — Manages/oversees all Location Admins
   │
   ├── Location Admin — Village A
   │      — Registered businesses & people (Village A)
   │      — Transactions (Village A)
   │      — WhatsApp group(s) for Village A
   │
   ├── Location Admin — Village B
   │      — Registered businesses & people (Village B)
   │      — Transactions (Village B)
   │      — WhatsApp group(s) for Village B
   │
   └── Location Admin — Village C ...
```

**Notes / things to finalize:**
- Role-based access control (RBAC): Head Admin vs Location Admin permissions
- Can a Location Admin manage/edit data, or is access read-only (view analytics only)?
- Can there be more than 2 levels of hierarchy (e.g., Regional Admin between Head Admin and Location Admin) if the village count grows large?
- Admin login should be separate from the regular user login flow (or a role flag on the same login — to be decided)

---

## 6. Suggested App Structure

```
Village App (Flutter)
├── Onboarding
│   └── Registration (select Location from Location DB → WhatsApp group auto-assign)
│
├── Home
│   ├── Ads / Banners
│   ├── Events & Updates Feed
│   ├── Latest Across Services Slider
│   ├── Services Grid
│   ├── Emergency Contacts
│   └── Shops & Organizations Directory
│
├── Services
│   ├── Buy & Sell
│   ├── Library (Rent/Buy/Sell Books)
│   ├── Plants
│   ├── Ride Pool (choose Car or Bike)
│   ├── Pharmacy
│   ├── YouTube (Submit/View Videos)
│   ├── Cake Marketplace
│   ├── Delivery
│   └── [Future Services...]
│
├── Profile / Account
│   ├── My Listings
│   ├── My Orders/Requests
│   ├── My Location & WhatsApp Group
│   └── Settings
│
├── Admin Panel
│   ├── Location Admin Login
│   │      — Registered businesses/people, transactions, analytics (own location)
│   └── Head Admin Login
│          — Consolidated analytics across all Location Admins
│
└── Backend Sync (Phase 2)
    └── Connects to existing Admin Dashboard/Web App backend
```

---

## 7. Open Questions / To Be Decided
- User authentication method (phone/OTP, email, existing web app login?)
- Will each service have its own chat/contact mechanism between buyer-seller/rider-passenger?
- Payment integration — needed now or later (cash-on-delivery/meet first)?
- Admin dashboard: will it be extended to manage mobile-specific content, or reused as-is?
- Moderation/approval flow for listings, video submissions, and shop registrations
- WhatsApp Business API access/setup for automated group creation and member addition
- Max member limit per WhatsApp group before a new one is auto-created
- Exact permission boundaries between Location Admin and Head Admin (read-only vs. edit access)
- Whether hierarchy needs more than 2 levels (e.g., Regional Admin) as the app scales to more villages


### Media on service submissions

All eight service modules allow users to attach images and videos to their entry forms. Users can preview images/videos and remove files before submitting; attachments stay with the entry. Every module displays a mixed-media gallery with thumbnails, counts and a full-screen image/video viewer. Village YouTube accepts a video file or video link for review. The current prototype retains media in memory for the session; persistent server uploads are a future backend integration. See README and the design guidelines for supported formats and limits.


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

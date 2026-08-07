# PromosellsFlutter Roadmap

Flutter rewrite of `SampleTrackerFront2025`, same backend (`SampleTrackerAPIs`),
same visual identity as `AdroitERPFlutterNewUI`. This file is the source of
truth for what's built and what's left — check items off as they land, and
add sub-items if a stage turns out to need more than expected.

Work proceeds stage by stage, in order. Don't start a later stage before the
one before it is checked off, unless we explicitly agree to jump around.

**Backend target:** all development/testing must point at the DEMO API
(`https://demopromosellapis.adroitbureau.com/`), never the live production
one (`swlaccrapromosellapis.adroitbureau.com`) — test entries must not land
in the real database. This is `ApiConfig`'s default
(`lib/config/api_config.dart`); production is opt-in only, via
`--dart-define=API_BASE_URL=...` for an actual release build.

---

## Stage 0 — Foundation ✅ DONE

- [x] `flutter create` scaffold (Android + iOS + Web, `com.adroit.promosells_flutter`)
- [x] Pubspec dependencies (get, provider, http, google_fonts, shared_preferences,
      icon packs, image_picker, geolocator, google_maps_flutter, url_launcher)
- [x] PublicSans fonts copied in
- [x] Theme ported (`lib/theme/`) — light/dark `ThemeData`, primary red `#A90808`
- [x] Core widget library ported (`lib/widgets/`) — `MyText`, `MyButton`, `MyCard`,
      `MyContainer`, `MySpacing`, responsive helpers, `AppLoadingOverlay`
- [x] API config (`lib/config/api_config.dart`) pointing at SampleTrackerAPIs
- [x] Auth flow — `POST api/UserAccount/Login`, session persisted via
      `shared_preferences` (mirrors React's sessionStorage keys)
- [x] Login screen
- [x] Authenticated shell — drawer nav, admin-gated items, logout
- [x] Placeholder screens for every route below
- [x] `flutter analyze` / `flutter test` / `flutter build web` all pass
- [x] Local git repo, first commit (`8f05c7e`)

**Not yet done, deliberately deferred:**
- [ ] Push to `github.com/woody7/PromosellsFlutter` (you're handling this manually)
- [ ] Real app icon / logo / favicon (placeholder for now — swap in when Promosells
      branding assets exist)
- [ ] Backend `[Authorize]` hardening on SampleTrackerAPIs write endpoints
      (explicitly deferred by you, tracked in SampleTrackerAPIs, not here)

---

## Stage 1 — Stock List (new-customer drop-off) ✅ DONE

Ports `Stocklist.js` + `Modal.js` + `Customerdetails.js` + `OfficeCaptureFields.js`.
This is the first real screen because everything after it (drop-off modal on
the customer-detail screen, customer edit) reuses the camera/geo capture
widget built here.

- [x] Camera capture widget (`image_picker`) — office/customer photo
- [x] Geolocation capture widget (`geolocator`) — lat/long of customer office
- [x] Android permissions: camera, location (`AndroidManifest.xml`)
- [x] iOS permissions: `NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription`
      (`Info.plist`)
- [x] `GET api/stocklist/GetallStock` — stock list grouped by stockGroup
- [x] Stock quantity picker per item (port of `NumericCheckbox`)
- [x] New-customer detail form (company, tel, contact, address, ref no, drop-off type)
- [x] Phone number validation (port of `PhoneNumberValidation.js` — simplified to
      immediate validation instead of the original's debounce, see Decisions log)
- [x] Confirmation modal before submit
- [x] `POST api/StockTransactions/PostDropOff` (multipart: form fields + email + photo)
- [x] Navigate to report detail on success — `ReportStubScreen` placeholder
      until Stage 4 builds the real report detail screen

**Definition of done:** a field user can add a brand-new prospective
customer, select stock quantities, capture a photo + location, and submit a
drop-off — matching what `Stocklist.js` does today. ✅

**Bonus finding while building this stage:** the live React app's drop-off
submissions weren't actually saving stock items — `PostDropOff`/
`PostDropOffExistingCustomer` unconditionally overwrite the bound
`stockData` with `ParseStockData(data.StockDataJson)`
(`StockTransactionsController.cs:64,263`), and the React app never sent
`StockDataJson`, so every drop-off recorded only an incident note with zero
stock movement. Fixed in `Stocklist.js`/`DropOffModal.js` (React repo,
uncommitted pending your testing) and built correctly from the start here —
Flutter sends `StockDataJson` as JSON-encoded `[[stockListId, quantity], ...]`.

---

## Stage 2 — Customer List + Customer Detail (existing-customer transactions) ✅ DONE

Ports `customerlist.js` + `customerstock.jsx` + `DropOffModal.js` +
`PickupModal.js` + `SalesModal.js` + `AddIncidentModal.js`.

- [x] Customer list screen
  - [x] `GET api/ProspCustomers/GetAllCustomersOfUser?userEmail=` (User role)
  - [x] `GET api/ProspCustomers/GetAllCustomers` (Admin role)
  - [x] Tap-to-call (`url_launcher`, `tel:`)
  - [x] Navigate to customer detail
- [x] Customer detail screen
  - [x] `GET api/ProspCustomers/GetCustomerDetails?customerID=`
  - [x] `GET api/StockTransReports/StocksWithOneCustomer?CustomerID=`
  - [x] `GET api/ProspCustomers/GetCustomerIncidents?customerID=` (incident history table)
  - [x] Action buttons: Add Incident, Drop Off, Pick Up, Sales
- [x] Drop-off modal (existing customer)
  - [x] `GET api/stocklist/GetallStock`
  - [x] `POST api/StockTransactions/PostDropOffExistingCustomer?WebCustID=`
  - [x] Reuses Stage 1's camera/geo capture widget
- [x] Pickup modal
  - [x] `POST api/StockTransactions/PostPickUp`
- [x] Sales modal
  - [x] `POST api/StockTransactions/PostSale`
- [x] Add-incident modal
  - [x] `POST api/ProspCustomers/AddCustomerIncident`
- [x] All four write payloads include `email`

**Definition of done:** a field user can browse their customers, open one,
see its stock/incident history, and run drop-off/pickup/sale/incident
transactions against it. ✅

**Improvement over the React version:** there, the drop-off/pickup/sales
modals pass a no-op `onConfirm`, so the stock table on customerstock.jsx
doesn't refresh after a transaction — only Add Incident does. Here, every
transaction modal refreshes both the stock and incident lists on success
(`CustomerDetailController.refreshAfterTransaction`).

---

## Stage 3 — Customer Map ✅ DONE

Ports `CustomerMap.jsx`, which uses react-leaflet + OpenStreetMap tiles — no
API key, no billing account. Flutter equivalent: `flutter_map` (OSM tile
layer) + `latlong2`, already swapped into `pubspec.yaml` in place of
`google_maps_flutter`.

- [x] `GET api/ProspCustomers/GetAllCustomersOfUser` / `GetAllCustomers` (role-gated, same as Stage 2)
- [x] Markers at each customer's lat/long
- [x] Marker tap → "View Details" → navigates to Stage 2's customer detail screen
      (via a bottom sheet showing name/company/address first, matching the
      React version's marker-popup-then-button two-step, not instant navigation)

**Definition of done:** map view matching `CustomerMap.jsx`, marker tap opens
the same customer detail screen as the list view. ✅

---

## Stage 4 — Reports (list + detail) ✅ DONE

Ports `ReportList.jsx` + `Reportcomponents/Report.js`.

- [x] Report list screen — `GET api/StockTransReports/GetAllSampleTransReports`
- [x] Report detail screen — `GET api/StockTransReports/DisplayDropOffReport?ReportID=`
- [x] PDF export (`pdf` + `printing` packages)
- [x] Excel export (`excel` package) — see decisions log: React defines this
      but never wires it to a button; Flutter actually exposes it
- [x] Share (`share_plus` for Excel; `printing`'s built-in `sharePdf`/`layoutPdf`
      cover PDF share + print, so no separate share call was needed there)
- [x] Wired Stage 1/2's post-submit navigation to this screen (was stubbed
      via `ReportStubScreen`, now deleted — real navigation in
      `drop_off_confirmation_sheet.dart`, `drop_off_existing_customer_dialog.dart`,
      `pickup_sale_dialog.dart`)

**Definition of done:** report list browsable, individual report viewable,
exportable as PDF/Excel, shareable — matching `Report.js`. ✅

---

## Stage 5 — Incident Report by Date ✅ DONE

Ports `IncidentReportByDate.js`.

- [x] `GET api/UserAccount/ListUsers` (filter dropdown)
- [x] `GET api/Incidents/GetCustomerIncidentsAll` (Admin)
- [x] `GET api/Incidents/GetUserCustomerIncidentsForUser` (User)
- [x] Date range filter
- [x] "Copy as Text" (`Clipboard` from `flutter/services.dart`)
- [x] PDF export (`pdf` + `printing`, reuse Stage 4's setup)
- [x] CSV export (`share_plus`, reuse Stage 4's setup) — wasn't listed in this
      stage's original scope, but React's `handleExport` does it and the
      packages were already in place, so it was cheap to include for full parity

**Definition of done:** matches `IncidentReportByDate.js` — filter by
user/date range, copy-as-text, export PDF/CSV. ✅

---

## Stage 6 — Admin screens: Overview dashboard, User Management, Change Password

Ports `Overview.jsx` + `UserManagement.js` + `Changepassword.jsx`.

- [ ] **Decision needed:** chart package for Overview's pie/bar charts —
      AdroitERP's pubspec doesn't include one. Recommend `fl_chart` (most
      common Flutter choice); confirm before adding.
- [ ] Overview dashboard — 8 `GET api/AdminDashboard/*` endpoints (stock card,
      customer card, sales card, samples pie chart, top customers bar chart,
      top years bar chart, samples due for pickup table, upcoming
      sale/return reconciliation table)
- [ ] User Management — `GET api/UserAccount/ListUsers` (read-only, same as React today)
- [ ] Change Password — `POST api/UserAccount/ChangePassword`
      (**note:** the React version hardcodes `https://localhost:7151/...`
      instead of using its configured base URL — that's a bug in the React
      app; use `ApiConfig.baseUrl` here instead, don't replicate the bug)

**Definition of done:** admin-only dashboard with real charts/cards,
read-only user list, working change-password form.

---

## Stage 7 — Customer Edit

Ports `CustomerEditPage.jsx`.

- [ ] `GET api/ProspCustomers/GetCustomerDetails?customerID=`
- [ ] `POST api/ProspCustomers/UpdateCustomer`
- [ ] Reuses Stage 1's camera/geo capture widget for office photo/location updates

**Definition of done:** existing customer's details, photo, and location can
be edited and saved.

---

## Stage 8 — Cross-cutting behavior

Things that touch the whole app rather than one screen — do these once the
screens that need them exist, not necessarily all at once at the end.

- [ ] Session timeout: 10-minute inactivity → warning modal → 60s grace →
      auto-logout (mirrors `App.js`'s timer logic)
- [ ] Global error/loading conventions — confirm every screen uses
      `AppLoadingOverlay` and a consistent error-display pattern
- [ ] Role gating audit — re-check every admin-only screen/action against
      what `TopNavBar.js` / route-level checks actually gate today
- [ ] Offline/poor-connectivity behavior on submit actions (the React app
      has none today — decide whether Flutter should do better, e.g. retry
      or queue, or intentionally match parity first)

---

## Stage 9 — Release prep

- [ ] Real Promosells app icon, logo, splash screen, favicon (once assets exist)
- [ ] Replace placeholder spinner with a real branded one, if Promosells gets
      a brand animation (currently a plain themed `CircularProgressIndicator`)
- [ ] Android signing config + release build
- [ ] iOS signing/provisioning + release build
- [ ] Web build hosting decision (if the web target ships for real, vs.
      being mobile-only)
- [ ] Responsive/desktop web layout: right now every screen is plain
      mobile Material with no width constraints and a Drawer (mobile
      pattern) for nav — on a wide browser window content stretches
      awkwardly and the nav isn't discoverable. Needs a persistent sidebar
      on wide screens + max-width content constraints, matching what
      AdroitERP does with its `left_bar.dart` layout. Explicitly deferred
      until all screens exist — see Decisions log.
- [ ] Store listing assets (Play Store / App Store) if this replaces the
      web app for field use

---

## Open decisions / things to confirm with you before building

- [ ] Chart package for Stage 6 (`fl_chart` recommended)
- [ ] Share package for Stage 4 (`share_plus` recommended)
- [ ] Whether Stage 9's release prep is in scope now or a later, separate effort

## Decisions log

- **Map provider (Stage 3):** OpenStreetMap via `flutter_map` + `latlong2`,
  matching react-leaflet in the React app — not Google Maps. No API key
  needed. Decided 2026-08-07.
- **Phone validation (Stage 1):** validated immediately on change instead of
  React's ~1s debounced check — the debounce didn't change the outcome, just
  delayed it, so it was dropped rather than ported literally.
- **Drop-off stock data bug (Stage 1):** discovered the live React app never
  persisted selected stock items on drop-off (see Stage 1 notes above).
  Flutter's `StocklistApi.submitDropOff` sends the format the backend
  actually reads (`StockDataJson`); the matching React-side fix is written
  but not yet committed — you're testing it first.
- **Auto-refresh after transactions (Stage 2):** `customerstock.jsx` passes a
  no-op `onConfirm` to the drop-off/pickup/sales modals, so their React
  screen doesn't refresh after a transaction. `CustomerDetailController`
  refreshes stocks + incidents after every transaction modal instead — a
  UX fix with no data-integrity implications, not a behavior worth copying.
- **Web layout deferred:** the app looks rough on a wide browser window
  (Drawer nav not discoverable, no content width constraints) — confirmed
  and explicitly deferred to Stage 9 rather than fixed now, since the app
  is mobile-first (camera/GPS drop-off flows only make sense on a phone)
  and the remaining stages matter more than desktop polish right now.
  Decided 2026-08-07.
- **PDF generation (Stage 4):** built as a real vector PDF via the `pdf`
  package's widget system, not a screenshot — React's `exportToPDF`
  screenshots the DOM with html2canvas and embeds that image in a PDF.
  Flutter has no DOM to screenshot and the `pdf` package produces sharper,
  smaller, text-selectable output directly, so there was no reason to
  emulate the screenshot approach.
- **Excel export actually wired up (Stage 4):** `Report.js` defines
  `exportToExcel` but never renders a button for it — dead code (also
  flagged by ESLint during the earlier build check: "'exportToExcel' is
  assigned a value but never used"). Flutter exposes it as a real "Export
  Excel" button since the working code already existed, just unreachable.
- **Download vs. Share buttons (Stage 4):** on mobile there's no browser
  download folder — both buttons go through the OS share sheet
  (`Printing.sharePdf`), same call underneath. Kept as two buttons anyway
  to match the React layout and because the labels still signal different
  intent to the user, even though the mechanism is identical here.

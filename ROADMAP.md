# PromosellsFlutter Roadmap

Flutter rewrite of `SampleTrackerFront2025`, same backend (`SampleTrackerAPIs`),
same visual identity as `AdroitERPFlutterNewUI`. This file is the source of
truth for what's built and what's left — check items off as they land, and
add sub-items if a stage turns out to need more than expected.

Work proceeds stage by stage, in order. Don't start a later stage before the
one before it is checked off, unless we explicitly agree to jump around.

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

## Stage 1 — Stock List (new-customer drop-off)

Ports `Stocklist.js` + `Modal.js` + `Customerdetails.js` + `OfficeCaptureFields.js`.
This is the first real screen because everything after it (drop-off modal on
the customer-detail screen, customer edit) reuses the camera/geo capture
widget built here.

- [ ] Camera capture widget (`image_picker`) — office/customer photo
- [ ] Geolocation capture widget (`geolocator`) — lat/long of customer office
- [ ] Android permissions: camera, location (`AndroidManifest.xml`)
- [ ] iOS permissions: `NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription`
      (`Info.plist`)
- [ ] `GET api/stocklist/GetallStock` — stock list grouped by stockGroup
- [ ] Stock quantity picker per item (port of `NumericCheckbox`)
- [ ] New-customer detail form (company, tel, contact, address, ref no, drop-off type)
- [ ] Phone number validation (port of `PhoneNumberValidation.js`)
- [ ] Confirmation modal before submit
- [ ] `POST api/StockTransactions/PostDropOff` (multipart: form fields + email + photo)
- [ ] Navigate to report detail on success (Stage 4 dependency — stub the
      destination screen until Stage 4 lands)

**Definition of done:** a field user can add a brand-new prospective
customer, select stock quantities, capture a photo + location, and submit a
drop-off — matching what `Stocklist.js` does today.

---

## Stage 2 — Customer List + Customer Detail (existing-customer transactions)

Ports `customerlist.js` + `customerstock.jsx` + `DropOffModal.js` +
`PickupModal.js` + `SalesModal.js` + `AddIncidentModal.js`.

- [ ] Customer list screen
  - [ ] `GET api/ProspCustomers/GetAllCustomersOfUser?userEmail=` (User role)
  - [ ] `GET api/ProspCustomers/GetAllCustomers` (Admin role)
  - [ ] Tap-to-call (`url_launcher`, `tel:`)
  - [ ] Navigate to customer detail
- [ ] Customer detail screen
  - [ ] `GET api/ProspCustomers/GetCustomerDetails?customerID=`
  - [ ] `GET api/StockTransReports/StocksWithOneCustomer?CustomerID=`
  - [ ] `GET api/ProspCustomers/GetCustomerIncidents?customerId=` (incident history table)
  - [ ] Action buttons: Add Incident, Drop Off, Pick Up, Sales
- [ ] Drop-off modal (existing customer)
  - [ ] `GET api/stocklist/GetallStock`
  - [ ] `POST api/StockTransactions/PostDropOffExistingCustomer?WebCustID=`
  - [ ] Reuses Stage 1's camera/geo capture widget
- [ ] Pickup modal
  - [ ] `POST api/StockTransactions/PostPickUp`
- [ ] Sales modal
  - [ ] `POST api/StockTransactions/PostSale`
- [ ] Add-incident modal
  - [ ] `POST api/ProspCustomers/AddCustomerIncident`
- [ ] All four write payloads include `email` (per the recent backend fix —
      confirm the DTOs still carry `Email` when you build against latest SampleTrackerAPIs)

**Definition of done:** a field user can browse their customers, open one,
see its stock/incident history, and run drop-off/pickup/sale/incident
transactions against it.

---

## Stage 3 — Customer Map

Ports `CustomerMap.jsx`, which uses react-leaflet + OpenStreetMap tiles — no
API key, no billing account. Flutter equivalent: `flutter_map` (OSM tile
layer) + `latlong2`, already swapped into `pubspec.yaml` in place of
`google_maps_flutter`.

- [ ] `GET api/ProspCustomers/GetAllCustomersOfUser` / `GetAllCustomers` (role-gated, same as Stage 2)
- [ ] Markers at each customer's lat/long
- [ ] Marker tap → "View Details" → navigates to Stage 2's customer detail screen

**Definition of done:** map view matching `CustomerMap.jsx`, marker tap opens
the same customer detail screen as the list view.

---

## Stage 4 — Reports (list + detail)

Ports `ReportList.jsx` + `Reportcomponents/Report.js`.

- [ ] Report list screen — `GET api/StockTransReports/GetAllSampleTransReports`
- [ ] Report detail screen — `GET api/StockTransReports/DisplayDropOffReport?ReportID=`
- [ ] PDF export (`pdf` + `printing` packages — already in AdroitERP's pubspec)
- [ ] Excel export (`excel` package)
- [ ] Share (native share sheet, e.g. `share_plus` — **new package, not yet
      in pubspec.yaml**)
- [ ] Wire Stage 1/2's post-submit navigation to this screen (currently stubbed)

**Definition of done:** report list browsable, individual report viewable,
exportable as PDF/Excel, shareable — matching `Report.js`.

---

## Stage 5 — Incident Report by Date

Ports `IncidentReportByDate.js`.

- [ ] `GET api/UserAccount/ListUsers` (filter dropdown)
- [ ] `GET api/Incidents/GetCustomerIncidentsAll` (Admin)
- [ ] `GET api/Incidents/GetUserCustomerIncidentsForUser` (User)
- [ ] Date range filter
- [ ] "Copy as Text" (`Clipboard` from `flutter/services.dart` — no new package needed)
- [ ] PDF export (`pdf` + `printing`, reuse Stage 4's setup)

**Definition of done:** matches `IncidentReportByDate.js` — filter by
user/date range, copy-as-text, export PDF.

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

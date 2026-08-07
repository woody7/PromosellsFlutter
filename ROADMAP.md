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

## Stage 6 — Admin screens: Overview dashboard, User Management, Change Password ✅ DONE

Ports `Overview.jsx` + `UserManagement.js` + `Changepassword.jsx`.

- [x] Chart package: `fl_chart` (confirmed with you before adding)
- [x] Overview dashboard — 8 `GET api/AdminDashboard/*` endpoints (stock card,
      customer card, sales card, samples pie chart, top customers bar chart,
      top years bar chart, samples due for pickup table, upcoming
      sale/return reconciliation table)
- [x] User Management — `GET api/UserAccount/ListUsers` (read-only, same as React today)
- [x] Change Password — `POST api/UserAccount/ChangePassword`, using
      `ApiConfig.baseUrl` instead of the React version's hardcoded
      `https://localhost:7151/...`

**Definition of done:** admin-only dashboard with real charts/cards,
read-only user list, working change-password form. ✅

**Bonus finding while building this stage:** Change Password had the same
`_CurrentUser` singleton bug as the drop-off/pickup/sale/incident endpoints
fixed earlier — `ChangePasswordViewModel` carried no email, so the backend
resolved *whose* password to change entirely from the shared singleton. With
two people active around the same time, a password-change request could
validate against the wrong account. Fixed the same way: added an optional
`Email` to the DTO, preferred over the singleton when present
(SampleTrackerAPIs commit `87737cc`).

Two more gaps found and fixed only on the Flutter side (no backend changes,
since they're pure client-side implementation gaps in React, see Decisions
log): the React Change Password screen's success handler calls a prop
(`onChangePasswordSuccess`) that App.js never actually passes, so it throws
in the console instead of confirming anything; and "Confirm Password" is
captured but never compared against "New Password" anywhere, client or
server.

---

## Stage 7 — Customer Edit ✅ DONE

Ports `CustomerEditPage.jsx`.

- [x] `GET api/ProspCustomers/GetCustomerDetails?customerID=`
- [x] `POST api/ProspCustomers/UpdateCustomer`
- [x] Reuses Stage 1's camera/geo capture widget for office photo/location updates
- [x] Edit entry point on Customer List (dropped in Stage 2 pending this stage,
      added back now)

**Definition of done:** existing customer's details, photo, and location can
be edited and saved. ✅

**Bonus finding while building this stage:** `UpdateCustomer` had the same
`_CurrentUser` singleton bug as the other endpoints fixed earlier — the
audit-trail `ModifiedBy` field was attributed entirely from the shared
singleton, not the actual editing user. Lower stakes than the drop-off/
ChangePassword cases (just attribution, not data loss or account mixup),
but same root cause and fixed the same way: `UpdateCustomerViewModel` now
carries an optional `Email`, preferred over the singleton
(SampleTrackerAPIs commit `9fa47fd`).

---

## Stage 8 — Cross-cutting behavior ✅ DONE

Things that touch the whole app rather than one screen — do these once the
screens that need them exist, not necessarily all at once at the end.

- [x] Session timeout: 10-minute inactivity → warning modal → 60s grace →
      auto-logout (mirrors `App.js`'s timer logic) — `SessionTimeoutWrapper`,
      wrapping `AppShell` in `main.dart`'s `AuthGate`
- [x] Global error/loading conventions — audited (see Decisions log): error
      display is already 100% consistent (`colorScheme.error` + `MyText`,
      16 files); initial-page loading is already 100% consistent too, via
      a plain early-return pattern rather than literally reusing
      `AppLoadingOverlay` — see that widget's updated doc comment for why
- [x] Role gating audit — nav-level gating confirmed matching `TopNavBar.js`
      exactly (Stock Reports + Users, nothing else). Added defense-in-depth:
      `AccessDeniedView`, an internal Admin check inside `ReportListScreen`
      and `UserManagementScreen` themselves, matching the belt-and-suspenders
      pattern `ReportList.jsx`/`UserManagement.js` already use (their own
      internal check, independent of the nav hiding the link)
- [x] Offline/poor-connectivity decision: match parity, not build retry/queue
      infrastructure — see Decisions log

---

## Stage 9 — Release prep 🟡 IN PROGRESS

Unlike Stages 0–8, most of this depends on things only you can provide
(branding assets, developer accounts) rather than being pure code work —
tackled piece by piece as you're ready for each, not all at once.

- [x] Android signing config + release build — new upload keystore generated
      (`android/keystore/upload-keystore.jks`, gitignored, **not backed up
      anywhere else — see the warning below**), wired into
      `android/app/build.gradle.kts`, verified with `apksigner`: the release
      APK is genuinely signed with it, not falling back to the debug key.
- [x] Responsive/desktop web layout — `AppShell` now switches to a
      persistent sidebar + max-width-1200 centered content at ≥900px width;
      below that, unchanged mobile Drawer behavior. Closes the gap flagged
      back in Stage 2.
- [ ] Real Promosells app icon, logo, splash screen, favicon — **blocked on
      you having brand assets ready**
- [ ] Replace placeholder spinner with a real branded one, if Promosells gets
      a brand animation (currently a plain themed `CircularProgressIndicator`)
      — **blocked on brand assets**
- [ ] iOS signing/provisioning + release build — **blocked on an Apple
      Developer account**
- [ ] Web build hosting decision (if the web target ships for real, vs.
      being mobile-only) — **your call, not started**
- [ ] Store listing assets (Play Store / App Store) if this replaces the
      web app for field use — **not started**

**⚠️ Keystore backup warning:** `android/keystore/upload-keystore.jks` and
`android/key.properties` exist only on this machine, gitignored by design
(a signing key must never be committed). If this machine is lost without a
backup, you can never publish an update to this app under the same identity
on Play Store again — you'd have to ship it as a brand-new listing. Copy
both files somewhere safe (password manager, encrypted drive) before this
matters for real.

---

## Open decisions / things to confirm with you before building

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
- **User Management roles column (Stage 6):** left blank, matching the
  React version — the backend's `ListUsers` endpoint only ever returns
  `{ id, userName, email }`, no roles, so `user.roles?.join(', ')` in
  `UserManagement.js` always renders nothing. Not fixed, since it would mean
  a backend change (adding a per-user roles lookup) beyond this stage's scope;
  flagged here as a nice-to-have if it comes up later.
- **Change Password fixes are Flutter-only, not backend (Stage 6):** unlike
  the singleton bug (fixed in the backend, see above), two other gaps in
  `Changepassword.jsx` are pure client-side implementation gaps with no
  server-side counterpart to fix — its success handler calls a prop
  (`onChangePasswordSuccess`) that `App.js` never passes, and "Confirm
  Password" is captured but never compared against "New Password" anywhere,
  client or server. Both are just built correctly in the Flutter screen.
- **`AppLoadingOverlay` doc corrected, not the screens (Stage 8):** the
  widget's own doc comment claimed it should be used for a page's initial
  data load, but every screen actually uses a plain early-return instead
  (`if (isLoading) return const Center(child: CircularProgressIndicator())`)
  — and rightly so: `child` is a normal constructor argument, built eagerly
  by Dart even while `isLoading` is about to hide it, so a child that
  dereferences not-yet-loaded data would throw before the spinner ever
  swaps in. Fixed the doc comment to describe reality (and warn about the
  eager-construction trap) instead of refactoring 9 screens to force-fit a
  widget that's a genuine mismatch for this case — `AppLoadingOverlay`
  remains correctly used for in-place action overlays (e.g. the login
  button), which is what it's actually for.
- **Offline/poor-connectivity: match parity, not build retry/queue (Stage
  8):** the React app has no special handling for a dropped connection —
  a failed request just surfaces its error message, same as this app's
  consistent `colorScheme.error` pattern already does. Building retry or
  offline-queue infrastructure would be a substantial feature disproportionate
  to a cross-cutting polish stage; revisit only if it comes up as an actual
  problem for field use, not preemptively.
- **New upload keystore generated, not reusing an existing one (Stage 9):**
  you confirmed there wasn't one already. Stored at
  `android/keystore/upload-keystore.jks` with credentials in
  `android/key.properties`, both gitignored. **This machine is the only copy
  — back both files up before this matters for real** (see the warning in
  Stage 9 above). `build.gradle.kts` falls back to debug signing only if
  `key.properties` is absent, so a fresh checkout without the keystore still
  builds (just not release-signed) rather than failing outright.
- **Responsive breakpoint: 900px (Stage 9):** matches the threshold already
  used for the Overview dashboard's card/chart layout switch (Stage 6), so
  the whole app agrees on what counts as "wide" rather than each screen
  picking its own number.

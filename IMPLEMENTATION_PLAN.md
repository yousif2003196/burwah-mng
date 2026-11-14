# Implementation Plan — Berwah Supervisors API (integrate into the EXISTING Flutter project)

> **For Claude Code.** Implement this inside the **current project**. Do not create a new project and do not restructure what already exists.
> **Do NOT write any tests** — no unit, widget, golden, or integration tests.
> **Do NOT use `freezed`** (or `build_runner`-generated models). Write models by hand.
> **Use only what the API spec defines.** Do not invent endpoints, fields, or request bodies (see §2).

---

## Step 0 — Inspect the existing project first (mandatory, before writing code)

Read the project and follow what is already there. Report a short summary of findings before Phase 1.

1. **`pubspec.yaml`** — use the packages already installed. Only add a package if nothing existing covers the need, and say why.
2. **Folder structure** — find the existing feature-based layout (e.g. `lib/core`, `lib/features/<name>/{data,domain,presentation}`) and follow the same naming, file suffixes, and nesting.
3. **State management** — use whatever the project already uses (Cubit / Bloc / Riverpod). Copy the pattern of an existing feature (state classes, how they're provided, how errors are shown).
4. **Networking** — reuse the existing HTTP client (Dio/http instance, base URL config, interceptors, error handling, `ApiResponse`-style wrapper, `Failure`/`Exception` classes). Extend them; don't duplicate them.
5. **DI** — register new classes in the existing container/providers the same way existing features do.
6. **Routing** — add routes to the existing router (go_router / auto_route / Navigator) using its conventions.
7. **Local storage** — reuse the existing token/storage service (secure storage / Hive / SharedPreferences).
8. **Shared widgets, theme, strings, localization** — reuse existing buttons, text fields, loaders, error/empty views, dialogs, colors, text styles, and string/l10n system. Only create a new shared widget if no equivalent exists, and place it where existing shared widgets live.
9. **Existing auth / supervisor code** — if any of the endpoints below are already implemented, reuse and complete them instead of re-implementing.
10. **Model style** — copy the existing hand-written model style (`fromJson` factory, `toJson`, `Equatable` or not, entity vs model split).

If the project has no convention for something, use the defaults in §1.

---

## 1. Defaults (only where the project has no existing convention)

- Feature layout: `data/{datasources,models,repositories}`, `domain/{entities,repositories,usecases}`, `presentation/{cubit|providers,pages,widgets}`.
- Models: plain Dart classes, hand-written:
  ```dart
  class AdModel {
    final int id;
    final String title;
    // ...
    const AdModel({required this.id, required this.title});

    factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
          id: json['id'] as int,
          title: json['title'] as String? ?? '',
        );

    Map<String, dynamic> toJson() => {'id': id, 'title': title};

    Ad toEntity() => Ad(id: id, title: title);
  }
  ```
- Entities: immutable, `Equatable` if already a dependency.
- Repositories return the same result type the project already uses (e.g. `Either<Failure, T>` or a `Result` class).
- UI is Arabic / RTL (match the existing app locale setup).

---

## 2. Rules for unspecified API details

The spec defines endpoints, methods, login request/response, the `{status, data}` envelope, and **five sample responses only**. It does **not** define request bodies (other than login), query params, pagination, or error formats.

- **Do not guess.** For any endpoint whose request body or response shape isn't in this plan:
  1. First check whether the existing project already has a model/request for it — reuse it.
  2. Otherwise **stop and ask the user** for the request/response JSON for that endpoint before writing its model. Batch these questions per feature, not one by one.
- Model **only** the fields shown in the samples in §4. Don't add extra fields.
- Don't add pagination or filter params unless the user provides them.
- No refresh-token flow (no endpoint exists). Store `refreshToken` from login only.
- Keep all paths as constants in one endpoints file (existing one if present).

---

## 3. Auth & Role Routing

**Endpoint:** `POST /api/SupervisorForAd/LoginForSupervisor`
- Header: `X-Device-Id` (device identifier for session tracking). Reuse the existing device-id logic if present; otherwise generate once and persist.
- Body: `{ "email": "<email or phone>", "password": "<password>" }`

**Response (200):**
```json
{
  "status": "success",
  "message": "تم تسجيل الدخول بنجاح",
  "token": "eyJhbGciOi...",
  "refreshToken": "8f9c2a1b...",
  "data": {
    "userId": 19,
    "email": "admin@berwah.com",
    "name": "Admin Browah",
    "role": "SupervisorForAd",
    "lastLogin": "2026-11-14T15:30:00Z"
  }
}
```
Note: `token` and `refreshToken` are at the **top level**, not inside `data`.

**After login:** every request sends `Authorization: Bearer <token>` (add to the existing interceptor/client).

**Roles → section:**
| `role` value | Section |
|---|---|
| `SupervisorForAd` | Ads Review (`/api/SupervisorForAd/*`) |
| `SupervisorForMerchant` | Merchants (`/api/supervisor/merchant/*`) |
| `SupervisorForServices` | Service Requests (`/api/SupervisorForSR/*`) |
| `SupervisorUsed` | Used Goods & Wosally (`/api/SupervisorUsed/*`) |
| `Admin` | Access to all four sections (section picker) |

Implement:
- `SupervisorRole` enum parsed from the string (unknown values → unauthorized handling).
- Save token, refreshToken, and the `data` user object using the existing storage service.
- Route guard: on startup and after login, send the user to their section; block access to other sections unless `Admin`.
- Logout: clear stored session locally (no logout endpoint in the spec).

---

## 4. Features & Endpoints

Each endpoint → data source method → repository method → use case → reachable from UI.

### 4.1 Ads Review — `SupervisorForAd` (roles: SupervisorForAd, Admin)
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/SupervisorForAd/stats` | Dashboard stats (pending, approved, rejected) |
| GET | `/api/SupervisorForAd/pending-ads` | New ads awaiting review |
| GET | `/api/SupervisorForAd/ads` | All ads, filterable by status or category |
| GET | `/api/SupervisorForAd/ad/{id}` | Full ad details (images, specs, quantity, seller) |
| PUT | `/api/SupervisorForAd/ad/{id}` | Admin edit of ad data |
| POST | `/api/SupervisorForAd/update-ad-status/{id}` | Change status (approve & publish / suspend) |
| POST | `/api/SupervisorForAd/reject/{id}` | Reject with a reason shown to the user |
| POST | `/api/SupervisorForAd/hide/{id}` | Temporarily hide without deleting |
| GET | `/api/SupervisorForAd/reports` | User reports on ads |

**Sample — ad details:**
```json
{
  "status": "success",
  "data": {
    "id": 104,
    "title": "آيفون 15 برو ماكس جديد",
    "price": 52000.00,
    "quantity": 5,
    "status": "Pending",
    "governorate": "القاهرة",
    "city": "مدينة نصر",
    "sellerName": "محمد أحمد",
    "imageUrls": ["https://cdn.berwah.com/ads/104_1.jpg"],
    "specifications": [
      { "id": 12, "key": "السعة التخزينية", "value": "256 جيجابايت" }
    ]
  }
}
```
Entities: `Ad`, `AdSpecification {id, key, value}`.

**Screens:** Dashboard (stats) · Pending ads list · All ads list (status/category filter) · Ad details (actions: approve, suspend, reject with reason, hide, edit) · Edit ad · Reports list.

### 4.2 Merchants — `SupervisorForMerchant` (roles: SupervisorForMerchant, Admin)
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/supervisor/merchant/stats` | Stats for merchants under this supervisor |
| GET | `/api/supervisor/merchant/merchants` | Managed merchants list (search & filter) |
| POST | `/api/supervisor/merchant/merchants/add` | Add a merchant to supervisor's list |
| GET | `/api/supervisor/merchant/merchant/{merchantId}/profile` | Merchant profile (commercial register, commission) |
| GET | `/api/supervisor/merchant/merchant/{merchantId}/pending-ads` | Pending ads of a specific merchant |
| POST | `/api/supervisor/merchant/merchant/{merchantId}/suspend` | Suspend/activate store with documented reason |
| POST | `/api/supervisor/merchant/merchant/{merchantId}/commission` | Update platform commission rate |
| GET | `/api/supervisor/merchant/ads/stats` | Merchant ads stats (pending, approved) |
| GET | `/api/supervisor/merchant/ads/pending` | All merchant ads awaiting review |
| GET | `/api/supervisor/merchant/ads/{id}/details` | Merchant ad details |
| POST | `/api/supervisor/merchant/ads/{id}/approve` | Approve & publish in store |
| POST | `/api/supervisor/merchant/ads/{id}/reject` | Reject with reason |
| POST | `/api/supervisor/merchant/ads/{id}/request-edit` | Send note to merchant to edit before approval |

**Sample — merchant profile:**
```json
{
  "status": "success",
  "data": {
    "merchantId": 42,
    "storeName": "معرض النخبة للأجهزة",
    "commercialRegister": "1010482910",
    "ownerName": "أحمد محمود",
    "commissionRate": 5.0,
    "isSuspended": false,
    "pendingAdsCount": 3
  }
}
```
Entity: `MerchantProfile`.

**Screens:** Dashboard (merchant stats + merchant-ads stats) · Merchants list (+ add) · Merchant profile (suspend/activate, update commission, pending ads) · Pending merchant ads · Merchant ad details (approve, reject, request edit).

### 4.3 Service Requests — `SupervisorForSR` (roles: SupervisorForServices, Admin)
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/SupervisorForSR/stats` | Stats (pending, in progress, completed) |
| GET | `/api/SupervisorForSR/pending` | New requests awaiting review |
| GET | `/api/SupervisorForSR/requests` | All requests, all statuses |
| GET | `/api/SupervisorForSR/details/{id}` | Request details |
| POST | `/api/SupervisorForSR/approve/{id}` | Approve & make available to providers |
| POST | `/api/SupervisorForSR/reject/{id}` | Reject with reason |
| POST | `/api/SupervisorForSR/update-and-approve/{id}` | Edit request data and approve in one step |
| POST | `/api/SupervisorForSR/request-info/{id}` | Ask customer for more info |
| POST | `/api/SupervisorForSR/return-request/{id}` | Return request to customer for edits |
| POST | `/api/SupervisorForSR/suspend-request/{id}` | Temporarily suspend request |
| POST | `/api/SupervisorForSR/escalate-request/{id}` | Escalate request to upper management |
| GET | `/api/SupervisorForSR/subcategories/{requestId}` | Subcategories available for reclassifying |
| POST | `/api/SupervisorForSR/update-category/{id}` | Change request category |
| GET | `/api/SupervisorForSR/providers-directory` | Providers directory with ratings |
| GET | `/api/SupervisorForSR/provider-professional-profile/{providerId}` | Provider profile & work history |
| POST | `/api/SupervisorForSR/provider-state/{providerId}` | Activate/deactivate provider |
| POST | `/api/SupervisorForSR/reassign/{requestId}` | Reassign request to another provider |
| GET | `/api/SupervisorForSR/complaint/stats` | Complaint stats (open, closed) |
| GET | `/api/SupervisorForSR/list` | Service complaints & disputes |
| POST | `/api/SupervisorForSR/escalate/{id}` | Escalate complaint to upper management |
| POST | `/api/SupervisorForSR/enforce-compensation/{id}` | Enforce compensation for the harmed party |
| GET | `/api/SupervisorForSR/advanced-wallet` | Advanced wallet balance & transactions |
| POST | `/api/SupervisorForSR/advanced-wallet/withdraw` | Withdrawal request |
| GET | `/api/SupervisorForSR/account-settings` | Account settings |

**Sample — request details:**
```json
{
  "status": "success",
  "data": {
    "id": 519,
    "serviceTitle": "صيانة تكييف مركزي",
    "status": "Pending",
    "customerName": "سعيد عبد الله",
    "providerName": null,
    "budget": 450.00,
    "governorate": "الجيزة",
    "createdAt": "2026-11-14T10:15:00Z"
  }
}
```
Entity: `ServiceRequest` (`providerName` nullable).

This feature is large — split the data layer into separate data sources/repositories for: requests, providers, complaints, wallet & settings.

**Screens:** Dashboard (request + complaint stats) · Requests (pending / all) · Request details (approve, edit & approve, request info, return, suspend, escalate, reject, change category, reassign) · Providers directory · Provider profile (activate/deactivate) · Complaints list (escalate, enforce compensation) · Advanced wallet (withdraw) · Account settings.

### 4.4 Used Goods & Wosally — `SupervisorUsed` (roles: SupervisorUsed, Admin)
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/SupervisorUsed/stats` | Used goods & Wosally stats |
| GET | `/api/SupervisorUsed` | Used ads list with filtering |
| GET | `/api/SupervisorUsed/{id}` | Used ad details & condition |
| POST | `/api/SupervisorUsed/{id}/approve` | Approve & publish |
| POST | `/api/SupervisorUsed/{id}/request-edit` | Ask seller to edit |
| POST | `/api/SupervisorUsed/{id}/suspend` | Temporarily suspend |
| POST | `/api/SupervisorUsed/{id}/reject-with-penalty` | Reject and apply a penalty/violation |
| GET | `/api/SupervisorUsed/wosally-orders` | Wosally orders list |
| GET | `/api/SupervisorUsed/wosally-orders/{id}` | Wosally order details (seller, buyer, product) |
| POST | `/api/SupervisorUsed/wosally-orders/{id}/approve-and-reveal` | Approve & reveal contact info to both parties |
| POST | `/api/SupervisorUsed/wosally-orders/{id}/send-joint-alert` | Joint alert to seller and buyer |
| GET | `/api/SupervisorUsed/complaints` | Used-goods complaints |
| GET | `/api/SupervisorUsed/complaints/{id}/details` | Complaint details & evidence |
| POST | `/api/SupervisorUsed/complaints/{id}/follow-up` | Log a follow-up action |
| POST | `/api/SupervisorUsed/complaints/{id}/send-to-seller` | Send official notice/inquiry to seller |
| POST | `/api/SupervisorUsed/complaints/{id}/escalate` | Escalate to upper management |
| GET | `/api/SupervisorUsed/wallet` | Wallet balance & transactions |

**Sample — Wosally order:**
```json
{
  "status": "success",
  "data": {
    "orderId": 88,
    "adTitle": "لابتوب ديل مستعمل بحالة ممتازة",
    "buyerName": "كريم حسن",
    "sellerName": "طارق علي",
    "status": "PendingApproval",
    "contactRevealed": false,
    "createdAt": "2026-11-14T12:40:00Z"
  }
}
```
Entity: `WosallyOrder`. Disable "Approve & Reveal" when `contactRevealed == true`, and confirm before revealing.

**Screens:** Dashboard · Used ads list → details (approve, request edit, suspend, reject with penalty) · Wosally orders → details (approve & reveal, joint alert) · Complaints → details (follow-up, send to seller, escalate) · Wallet.

---

## 5. Implementation Order

1. Step 0 inspection + summary.
2. Endpoint constants + `X-Device-Id` / Bearer headers in the existing client.
3. Auth (login, session storage, role enum, route guard, Admin section picker, logout).
4. Ads Review.
5. Merchants.
6. Service Requests.
7. Used Goods & Wosally.
8. Final pass: every endpoint reachable from UI, consistent loading/error/empty states using existing widgets, no double submits on action buttons, `flutter analyze` clean.

Before each feature (4–7), list the endpoints whose request/response JSON is still unknown and ask the user for it (§2).

## 6. Out of Scope
- Any tests.
- `freezed`, `json_serializable`, or other code generation for models.
- New endpoints, fields, pagination, or refresh-token flow not in the spec.
- Refactoring existing project code unrelated to this feature.

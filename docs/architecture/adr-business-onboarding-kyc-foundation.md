# ADR: Business onboarding, verification va KYC foundation (Phase 07)

**Status:** Accepted (schema Part 1; owner HTTP APIs Part 2; document metadata Part 3; **reviewer authorization foundation Part 4**)
**Date:** 2026-10-14 (updated Part 4)
**Scope:** `backend/` — onboarding + role assignments through Alembic **`b0a1f0110001`**, owner routes under `/api/v1/business/onboarding`

## Kontekst (Context)

QO‘SHNI da haqiqiy biznes ro‘yxatdan o‘tkazish (onboarding) autentifikatsiyadan alohida qatlam bo‘lishi kerak. Flutter **Business Center** dagi demo draftlar (`BusinessProfileKind.sampleDemo` / `userDraft`) faqat qurilmada qoladi; ular bu jadvalga yozilmaydi va **verified business** hisoblanmaydi.

## Qaror (Decision)

### Manba va egalik (Source of truth)

| Qatlam | Manba | Egalik |
|--------|--------|--------|
| Autentifikatsiya | `users` (UUID, telefon) | Shaxsiy identifikatsiya |
| Foydalanuvchi profili | `user_profiles`, `user_preferences` (Phase 06) | Display name, locale |
| **Biznes onboarding** | `business_onboarding_applications` | Yuridik/trade nom, kategoriya, registratsiya, **server-owned** `verification_status` |
| Kelajakdagi public business profile | Phase 08 (hali emas) | Faqat **verified** onboarding asosida |

- `owner_user_id` → `users.id` (FK, CASCADE). Bir foydalanuvchi **bir nechta** ariza ochishi mumkin (multi-business).
- Telefon raqami, OTP, tokenlar onboarding jadvalida **saqlanmaydi**.
- `business_contact_email` — biznes bilan bog‘lanish uchun ixtiyoriy email; hali alohida verify qilinmaydi.

### Verification status lifecycle

`verification_status` (`VerificationStatus`):

| Status | Ma’nosi |
|--------|---------|
| `draft` | Egasi draft maydonlarni tahrirlaydi |
| `submitted` | Ko‘rib chiqish navbatida |
| `under_review` | Reviewer jarayoni boshlangan |
| `verified` | Belgilangan review tartibi tugagan (keyingi sifat kafolati emas) |
| `rejected` | `rejection_reason_code` bilan (ichki reviewer note emas) |
| `suspended` | Privileged suspend |

**Ruxsat etilgan o‘tishlar** (`app/domain/business_onboarding.py` + `onboarding_service.py`):

- **Owner (implemented):** faqat `draft` → `submitted`.
- **Reviewer / system (deferred):** `submitted` → `under_review` → `verified` | `rejected`; `verified` → `suspended`; `suspended` → `under_review` | `verified`; `rejected` → `draft`.

**Xavfsizlik:**

- Owner o‘zini **verified** qila olmaydi (domain guard + PATCH da status maydoni yo‘q).
- Cross-owner o‘qish **404** `application_not_found` (enumeration oldini olish).
- Privileged `/internal/...` route'lar **mount qilinmagan** — review workflow hali yo‘q.
- **Part 4:** `business_onboarding_reviewer` roli faqat `user_platform_role_assignments` jadvalidan; token/profile orqali berilmaydi.

### Implemented owner APIs (Part 2)

Bearer token talab qilinadi (`get_current_principal`). `owner_user_id` faqat tokendan.

| Method | Path | Maqsad |
|--------|------|--------|
| POST | `/api/v1/business/onboarding/applications` | Draft ariza boshlash (+ ixtiyoriy seed maydonlar) |
| GET | `/api/v1/business/onboarding/applications` | Egasining arizalari |
| GET | `/api/v1/business/onboarding/applications/{id}` | Bitta ariza (owner scope) |
| PATCH | `/api/v1/business/onboarding/applications/{id}` | Faqat `draft` maydonlari |
| POST | `/api/v1/business/onboarding/applications/{id}/submit` | Review uchun yuborish |
| GET | `/api/v1/business/onboarding/applications/{id}/verification-status` | Status ko‘rinishi (tax/audit yo‘q) |

**Owner PATCH** ruxsat etilgan maydonlar: `OnboardingApplicationDraftUpdateRequest` dagi draft maydonlar va `clear_*` flaglar. Server maydonlari (`verification_status`, `rejection_reason_code`, `submitted_at`, `reviewed_at`, audit) client orqali o‘zgartirilmaydi.

**Owner response** (`OwnerOnboardingApplicationView`): egasining `tax_identifier` va registratsiya identifikatorlari ko‘rinadi; bu public business profile emas.

### Submit, audit va idempotency

- Submit: `SELECT … FOR UPDATE`, domain transition guard, validation, keyin **bir transaction** ichida status + `submitted_at` + audit `submitted`.
- **Idempotent retry:** agar status allaqachon `submitted` bo‘lsa, 200 qaytariladi va **yangi** `submitted` audit yozilmaydi.
- Create: audit `application_created`. PATCH: audit `draft_updated` (minimal, PII/details siz).
- Audit `actor_user_id` — authenticated principal; `actor_role` server tomonidan `owner` qo‘yiladi (client forge qila olmaydi).

### Duplicate business policy (Part 2 + Part 2.1)

- **Submit vaqtida** application-level tekshiruv + **DB partial unique index** `uq_business_onboarding_active_registration` (Alembic **`b0a1f0090001`**).
- **Kalit:** `(registration_jurisdiction, registration_identifier)` faqat **active** statuslar uchun: `submitted`, `under_review`, `verified`, `suspended`.
- **Draft** va **rejected** arizalar indeksga kirmaydi — bir xil identifikator bilan ko‘p draft yoki rejected + yangi submit ruxsat etiladi (indeks predicate bo‘yicha).
- **NULL** yoki faqat bo‘shliq identifikator indeksdan chiqariladi; saqlashda `registration_identifier = trim(...)` CHECK (`registration_identifier_trimmed`).
- **Tax ID** duplicate qoidasi yo‘q.
- **API xato:** `422` `validation_failed`, xabar: *An application with this registration identifier is already in review.* — boshqa egasining ID/nomi/tax ma’lumotlari yo‘q.
- **Race:** `IntegrityError` (faqat shu indeks) → `session.rollback()` → xuddi shu generic javob; muvaffaqiyatsiz submit audit qoldirmaydi.
- **Migration preflight:** mavjud active duplicate bo‘lsa, upgrade **xato** bilan to‘xtaydi (ma’lumot o‘chirilmaydi).
- **Test cheklovi:** SQLite deterministik unique + alohida session testlari; **PostgreSQL parallel concurrency testi CI da ishlamagan** — production PostgreSQL da indeks race-safe deb dizaynlangan.

### Private business documents (Part 3 — metadata only)

**Implemented:** SQLAlchemy model `BusinessOnboardingDocument`, jadval `business_onboarding_documents` (Alembic **`b0a1f0100001`**).

| Maydon | Ma’nosi |
|--------|---------|
| `id` | Barqaror document UUID |
| `application_id` | FK → `business_onboarding_applications` (CASCADE) |
| `uploaded_by_user_id` | FK → `users.id` — uploader/owner reference (server yozadi) |
| `document_type` | `BusinessOnboardingDocumentType` enum (CHECK) |
| `storage_object_key` | **Opaque** private object key (unique, trimmed, non-blank) — **public URL emas** |
| `lifecycle_state` | `BusinessOnboardingDocumentLifecycle` (default **`awaiting_upload`**) |
| `declared_content_type`, `byte_size`, `checksum_sha256` | Faqat kelajakdagi server-side tekshiruv uchun e’lon; client isboti emas |
| `created_at`, `updated_at` | Audit va UI metadata |

**Qilinmaydi (Part 3):** binary upload, object storage integratsiyasi, MIME/size/checksum server validation, malware scan, OCR, owner/reviewer HTTP route mount.

**Storage key vs public URL:** `storage_object_key` faqat backend/private storage layer uchun. Owner DTO (`OwnerOnboardingDocumentView`) storage key, checksum va fayl baytlarini **o‘z ichiga olmaydi**. Public business profile (Phase 08) va verification-status javoblari hujjat metadata qo‘shmaydi.

**Kelajakdagi ish oqimi (hali implement emas):**

1. Owner-authorized upload initiation (metadata slot + signed private upload).
2. Private storage ga yuklash.
3. Server-side haqiqiy content type, hajm va checksum tekshiruvi (`uploaded_pending_validation`).
4. Malware scan / quarantine (`quarantined`) — skaner ishlaguncha “verified/safe” holat yo‘q.
5. Ixtiyoriy OCR yoki manual review.
6. Reviewer acceptance/rejection (`accepted_for_review` / `rejected`) — faqat real privileged auth bilan.
7. Strictly authorized download (`/internal/.../content` contract, hali mount emas).

**Lifecycle holatlari:** enum kelajak o‘tishlar uchun to‘liq; Part 3 da faqat **`awaiting_upload`** default va haqiqiy yaratilgan qatorlar uchun ishlatiladi. “Verified”, “safe” yoki “approved” document holati **yo‘q** — skan/review jarayoni bo‘lmaguncha.

**Owner access boundary (design):**

- Faqat onboarding arizasining **authenticated owner**i o‘z arizasiga bog‘langan owner-visible document metadata ko‘radi.
- Egalik `get_current_principal` + `application.owner_user_id` orqali; client `owner_user_id` yubormaydi.
- Boshqa owner uchun 404 (enumeration yo‘q).
- Bir user bir nechta business ochishi mumkin; hujjat boshqa owner arizasiga biriktirilmasligi service qatlamida tekshiriladi (endpointlar kelganda).

### Server-side reviewer authorization (Part 4 — foundation only)

**Implemented:**

- Jadval `user_platform_role_assignments` (Alembic **`b0a1f0110001`**).
- Yagona hozirgi rol: **`business_onboarding_reviewer`** (`PlatformRole`).
- Faol grant: `revoked_at IS NULL` va (`expires_at IS NULL` yoki `expires_at > now()`).
- Partial unique index `uq_user_platform_role_assignment_active` — bir user uchun bir vaqtning o‘zida bitta faol `(user_id, role)`.
- Revoke + yangi qator orqali **re-grant** (tarix o‘chirilmaydi).
- FastAPI dependency `require_business_onboarding_reviewer`: avval `get_current_principal`, keyin DB dan grant; yo‘q/muddati o‘tgan/revoke → **403** `authorization_denied`; sessiya yo‘q → **401**; `suspended`/`disabled` → mavjud **403** `account_unavailable`.
- Permission mapping: `app/domain/reviewer_permissions.py` — faqat onboarding read/decision scope'lari; platform admin, payment, user management **yo‘q**.
- Self-review guard: `assert_reviewer_not_application_owner` — reviewer `user_id` == `owner_user_id` bo‘lsa generic **403/forbidden** (review ma’lumotlari oshkor etilmaydi).

**Grant maydonlari (qisqa):** `granted_at`, ixtiyoriy `expires_at`, `revoked_at` + `revocation_reason`, ixtiyoriy `granted_by_user_id`, `grant_source` (`operator_control_plane` | kelajak `role_admin_api`), ixtiyoriy `grant_reference` (audit ticket ID, secret emas).

**Bootstrap cheklovi (hali):**

- Migration **hech qanday** reviewer grant seed qilmaydi.
- Public grant/revoke API, admin UI, hard-coded admin, email allowlist, bootstrap token **yo‘q**.
- Operator grant/revoke alohida nazorat ostidagi protsedura (control plane / DB ops) — `grant_source=operator_control_plane`; bu increment inson identifikatsiyasini tasdiqlamaydi; mustaqil operator audit keyinchalik talab qilinadi.
- Profile/onboarding API orqali rol **yozib bo‘lmaydi** (`extra=forbid`).

**Hali implement emas:**

- `/internal/business/onboarding/...` review decision route'lar (`begin-review`, `verify`, `reject`, …) — contract **`implemented=False`**, mount yo‘q.
- Document internal route'lar — **`implemented=False`**.
- KYC approval workflow, reviewer notes UI, role-admin HTTP API.

**Kelajak audit (role management):** grant/revoke operator actionlari alohida audit jadvali yoki auth audit kengaytmasi orqali yoziladi — Part 4 da jadval qo‘shilmadi.

### Sensitive data va audit

- `tax_identifier` faqat owner application ko‘rinishida; verification-status endpointida yo‘q.
- Hujjat binary DB da saqlanmaydi; audit `details` da hujjat kontenti, tax ID, storage key, token, OTP **yo‘q**.
- Mavjud `BusinessOnboardingAuditEvent` kelajak document eventlari uchun ishlatiladi (masalan `document_registered`, `document_quarantined` — enum kengaytirish keyingi increment). Part 3 da yangi audit jadvali yo‘q.
- Owner `actor_role=reviewer` forge qila olmaydi (mavjud owner audit qoidalari).

### Privileged API (deferred)

`/internal/business/onboarding/applications/{id}/begin-review|verify|reject|suspend|reinstate` — contract metadata `implemented=False`, **router mount yo‘q**.

Shuningdek document: `GET/POST .../internal/.../documents`, `.../content` — **`implemented=False`**, mount yo‘q.

### Phase 08 integratsiyasi

Verified onboarding yozuvi keyinchalik **Business Profile**, filiallar va staff/roles uchun manba bo‘ladi.

## Oqibatlar (Consequences)

- Alembic head: **`b0a1f0110001`** (`user_platform_role_assignments`).
- Owner onboarding HTTP handlerlari `app/api/routes/business_onboarding.py` da.
- Reviewer auth dependency: `app/api/deps/reviewer.py` (hali production route'larga ulanmagan).
- Document metadata: `app/domain/business_onboarding_documents.py`, contracts only.
- Flutter onboarding UI, real upload, OCR, privileged review HTTP — keyingi incrementlar.

## Keyingi ish

- `/internal/*` review workflow (mount + service + audit) — `require_business_onboarding_reviewer` ga ulanadi.
- Operator/role-admin grant-revoke API va audit.
- Owner document register/list/upload-init route'lar + private storage provider.
- Server validation, malware scan, OCR, privileged download.
- Audit enum kengaytirish (document lifecycle events).
- Rejected → draft rework flow (privileged yoki owner qoidasi).

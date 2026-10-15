# ADR: Business onboarding, verification va KYC foundation (Phase 07)

**Status:** Accepted (schema Part 1; **owner HTTP APIs Part 2**)
**Date:** 2026-10-14 (updated Part 2)
**Scope:** `backend/` — models, Alembic `b0a1f0080001`, owner routes under `/api/v1/business/onboarding`

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
- Privileged `/internal/...` route'lar **mount qilinmagan** — reviewer principal mavjud emas.

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

### Duplicate business policy (Part 2)

- **Migration o‘zgarmadi.** Global UNIQUE qo‘shilmadi.
- **Submit vaqtida:** agar bir xil `registration_jurisdiction` + `registration_identifier` (trim qilingan, bo‘sh emas) bilan boshqa ariza `submitted` | `under_review` | `verified` | `suspended` holatda bo‘lsa, submit **422** `validation_failed` (boshqa egasining ma’lumotlari oshkor qilinmaydi).
- **Tax ID** duplicate tekshiruvi yo‘q (har biznesda bo‘lmasligi mumkin).
- **Race limitation:** ikki parallel submit bir xil identifikator bilan ikkala transaction o‘tkazishi mumkin; to‘liq race-safe enforcement uchun kelajakda DB partial unique index yoki aniq biznes qarori kerak.

### Sensitive data va hujjatlar

- `tax_identifier` faqat owner API ko‘rinishida; verification-status endpointida yo‘q.
- Hujjatlar DB blob sifatida saqlanmaydi; kelajakda private `business_document_refs`.
- Audit jadvalida tax, hujjat, token, OTP yo‘q.

### Privileged API (deferred)

`/internal/business/onboarding/applications/{id}/begin-review|verify|reject|suspend|reinstate` — contract metadata `implemented=False`, **router mount yo‘q**. Reviewer/admin autentifikatsiyasi loyihalanguncha fake approval yo‘q.

### Phase 08 integratsiyasi

Verified onboarding yozuvi keyinchalik **Business Profile**, filiallar va staff/roles uchun manba bo‘ladi.

## Oqibatlar (Consequences)

- Alembic head: **`b0a1f0080001`** (o‘zgarmadi Part 2 da).
- Owner onboarding HTTP handlerlari `app/api/routes/business_onboarding.py` da.
- Flutter onboarding UI, hujjat upload, OCR, reviewer login — keyingi incrementlar.

## Keyingi ish

- Reviewer/admin principal va `/internal/*` implementatsiyasi.
- Document storage, OCR, malware scan.
- Race-safe duplicate enforcement (agar biznes qarori qabul qilinsa).
- Rejected → draft rework flow (privileged yoki owner qoidasi).

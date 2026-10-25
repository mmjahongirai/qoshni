# Platform governance workflows (frontend demo)

Phase 15 covers admin identity, queues, configuration, audit, approvals, and an operations dashboard — all in-memory under `lib/features/platform_governance/`.

## Ownership

| Area | Repository / controller | Notes |
|------|-------------------------|-------|
| Admin identities & roles | `QoshniPlatformGovernanceRepository` | Phase 15.1 seed |
| Business verification queue | `QoshniPlatformBusinessVerificationQueueRepository` | Per-submission history |
| Moderation queue | `QoshniPlatformModerationQueueRepository` | Does not mutate Phase 13 |
| Support cases | `QoshniPlatformSupportCaseRepository` | Internal notes only |
| Platform configuration | `QoshniPlatformConfigurationRepository` | Revision history separate from audit |
| Governance audit | `QoshniPlatformGovernanceAuditRepository` | Append-only supplement to queue histories |
| Maker-checker approvals | `QoshniPlatformApprovalRepository` | Lifecycle only — no execution |
| Operations dashboard | `QoshniPlatformGovernanceOperationsSummaryService` | Read-only aggregates |

## Authorization sequence

1. Validate input and target record.
2. `QoshniPlatformGovernanceAuthorizer.authorize` with typed permission and explicit scope.
3. On deny: **no domain mutation**; append audit when possible.
4. On allow: domain mutation, then append audit (mutation → audit ordering).

Default deny for missing permission, suspended admin, disabled role, or scope mismatch. Frontend policy is **not** production security.

## Audit append semantics (Work Package 3)

- Ordering: validate → authorize → mutate → append audit event.
- Denied authorization records a denial event without mutating the target.
- If audit append fails after a successful mutation, the UI reports `auditPersistFailure` and `auditRecorded: false`. The in-memory store is **not** transactionally atomic across crashes or concurrent writers.
- Duplicate `correlationReference` values are rejected.
- Seed events are labelled `isSeedRecord: true`.

## Configuration

- View: `viewPlatformConfiguration` (platform-wide scope).
- Low-risk writes: `manageLowRiskPlatformConfiguration` with matching platform or business scope.
- High-risk keys (e.g. payment provider mode) are marked restricted and non-editable; maker-checker is required in a future phase.
- Secret-like values in user input are rejected; credentials never appear in UI or audit payloads.

## Maker-checker approvals

- Submit: `submitHighRiskAdministrativeProposal` (demo operations admin).
- Decide: `decideHighRiskAdministrativeProposal` (demo `role-governance-approver` only).
- Requester cannot approve their own request.
- Approval updates the demo request status only — **no** wallet, refund, payment, or account-security execution.

## Synthetic data boundaries

- Synthetic admin references, business/branch IDs, and safe summaries only.
- No passwords, tokens, phone numbers, email content, or uploaded documents.
- Dashboard counts are labelled demo/synthetic — not operational KPIs.

## Out of scope

Backend JWT, durable audit storage, real KYC/moderation/support, financial adjustments, secret management, production feature flags, and infrastructure metrics.

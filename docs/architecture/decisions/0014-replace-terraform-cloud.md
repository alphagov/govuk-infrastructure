# 14. Replace Terraform Cloud backend with AWS S3

Date: 2025-06-10

## Status

Accepted

## Context

GOV.UK's infrastructure-as‑code currently stores Terraform state in **Terraform Cloud**. We have **93 workspaces** (each
with integration, staging, and production environments) and pay a lot for the service.

While Terraform Cloud gives us managed state, variable sets, secret interpolation, and a friendly UI, its cost and
proprietary lock‑in are no longer acceptable. A renewal decision is due within six months.

S3‑backed state with S3 native locking has matured, and AWS already meets our security baseline (Server-Side Encryption (SSE)
using AWS Key Management Service (KMS), CloudTrail, GuardDuty). We estimate an annual cost of **<£100**, a >99% saving.

## Decision

* **Adopt S3 as the canonical Terraform backend** for all workspaces.
* Provision **one bucket per environment**:

    * `govuk-terraform-state-integration`
    * `govuk-terraform-state-staging`
    * `govuk-terraform-state-production`
      with versioning, bucket‑level public‑access blocks and SSE‑KMS.
* Retain object versions for **90 days** via an S3 lifecycle rule.
* Manage these resources through a shared `state-backend` Terraform module in `govuk-infrastructure`.
* Example workspace backend block:

  ```hcl
  terraform {
    backend "s3" {
      bucket         = "govuk-terraform-state-${ var.environment }"
      key            = "${ path_relative_to_include() }/terraform.tfstate"
      region         = "eu-west-2"
      encrypt        = true
    }
  }
  ```
* **Access controls**

    * CI role `github-actions-tf` (or *Atlantis*, pending spike) – write + lock.
    * Human role `govuk-platform-engineer` – read/write for break‑glass only.
* **Migration plan**: workspace‑by‑workspace, beginning with integration; fallback is to repoint the backend to
  Terraform Cloud.
* We will cancel the Terraform Cloud subscription once we have migrated all the workspaces; this ADR will move to *Accepted*.

## Consequences

### Positive

* Reduces infrastructure as code platform spend by ≥99%.
* Removes vendor lock‑in; state lives wholly inside our AWS org.
* Leverages existing AWS security tooling and auditing.
* Aligns with open source, Cloud Native Computing Foundation‑standard workflows.

### Negatives and risks

* Loss of Terraform Cloud convenience features (run UI, drift detection, cost estimation).
  *Mitigation:* self‑hosted GitHub Actions runner or Atlantis; `Infracost`; scheduled drift plans.
* Mis‑configured bucket access control lists or KMS access cab expose or corrupt state.
  *Mitigation:* module tests, CI policy checks, Slack alerts on failed state writes or locks.
* Pipeline‑runner security: anyone with repository write might gain infrastructure access.
  *Mitigation:* decide between hardened self‑hosted GitHub Actions runners or Atlantis.

  
### Follow‑ups

* Complete runner spike and update ADR with chosen solution.
* Automate monthly cost report comparing S3 spend and historical Terraform Cloud invoice.
* Document onboarding steps for new workspaces.

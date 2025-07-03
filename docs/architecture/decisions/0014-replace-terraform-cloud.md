# 14. Replace Terraform Cloud backend with AWS S3

Date: 2025-06-10

## Status

Pending

## Context

GOV.UK’s infrastructure-as‑code currently stores Terraform state in **Terraform Cloud**. We have **93 workspaces** (each with integration, staging and production environments) and pay a lot for the service.

While Terraform Cloud gives us managed state, variable sets, secret interpolation and a friendly UI, its cost and proprietary lock‑in are no longer acceptable. A renewal decision is due within six months.

S3‑backed state with S3 native locking has matured, and AWS already meets our security baseline (SSE‑KMS, CloudTrail, GuardDuty). We estimate an annual cost of **<£100**, a >99% saving.

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
* **Migration plan**: workspace‑by‑workspace, beginning with integration; fallback is to repoint the backend to Terraform Cloud.
* Terraform Cloud subscription will be cancelled once all workspaces are migrated; this ADR will move to *Accepted*.

## Consequences

### Positive

* Reduces IaC platform spend by ≥99%.
* Removes vendor lock‑in; state resides wholly inside our AWS org.
* Leverages existing AWS security tooling and auditing.
* Aligns with open source, CNCF‑standard workflows.

### Negatives/Risks

* Loss of TF Cloud convenience features (run UI, drift detection, cost estimation).
  *Mitigation:* self‑hosted GHA runner or Atlantis; Infracost; scheduled drift plans.
* Mis‑configured bucket ACLs/KMS may expose or corrupt state.
  *Mitigation:* module tests, CI policy checks, Slack alerts on failed state writes/locks.
* Pipeline‑runner security: anyone with repo write might gain infra access.
  *Mitigation:* decide between hardened self‑hosted GHA runners or Atlantis by D+14.

### Follow‑ups

* Complete runner spike and update ADR with chosen solution.
* Automate monthly cost report comparing S3 spend vs historical TF Cloud invoice.
* Document onboarding steps for new workspaces.

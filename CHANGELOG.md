# GOV.UK Platform Team Changelog

All notable changes, fixes, and incidents for the platform infrastructure will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### In Progress
- **PostgreSQL upgrade discovery** - inventorying all PostgreSQL 13 RDS instances and documenting upgrade paths to version 14 before November 2025 EOL.
- **Release app documentation** - creating system architecture and ERD diagrams for better team understanding and onboarding.
- **Lambda function updates** - upgrading or removing outdated Node.js Lambda functions.

### Planned for Next Week
- Delegate *.publishing.service.gov.uk subdomains to environment AWS accounts.
- Create manual validation process for ephemeral clusters.

---

## [2025-06-02] - Week of June 2nd

### Added
- **Team member**: @AP-Hunt joined from Forms team - welcome aboard! 🎉
- **Prometheus-adapter Chart** for Chat team's Horizontal Pod Autoscalers - enables scaling on custom metrics beyond CPU/Memory (e.g., Sidekiq queue depth). If you want to know more, check out the [ADR](https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0013-expose-external-metrics-for-hpa.md). We haven't written any documentation yet, but as soon as the AI-Chat application have tested and confirmed the implementation, we will update the documentation accordingly.
- **platformengineer IAM role** with cluster-admin Kubernetes access - preparation for upcoming cyber thumb process requirements.
- **IAM Access Analyzer** enabled across all of all our for better visibility into role usage and permissions.

### Changed
- **govuk-mirror dependencies** updated to Go 1.24.3.
- **Documentation** added for new platformengineer IAM role and access patterns.

### Fixed
- **Long-standing linter issues** in mirror application resolved.
- **IAM access key rotation** completed for keys that had failed previous rotation attempts.

### Security
- **IAM access keys rotated** - addressed keys that hadn't been rotated on schedule.

### Incidents
- No incidents this week ✅

### Notes
- ADR created for prometheus-adapter implementation
- Project board: https://github.com/orgs/alphagov/projects/71/views/13

---

## Format Guide

### Entry Types
- **Added**: New features, tools, or capabilities
- **Changed**: Modifications to existing functionality
- **Fixed**: Bug fixes and issue resolutions
- **Security**: Security-related updates and patches
- **Deprecated**: Features marked for future removal
- **Removed**: Features or tools that have been removed
- **Incidents**: Significant outages or service disruptions

### Incident Format
Include incident ID, date/time (UTC), brief description, impact duration, and any relevant details about resolution or lessons learned.

#!/usr/bin/env bash
#
# migrate-eso-stored-versions.sh
#
# Migrates External Secrets Operator (ESO) custom resources to the current CRD
# storage version, then prunes old versions from each CRD's
# status.storedVersions.
#
# Why? On EKS we cannot touch etcd directly. When a CRD's storage version
# changes, objects written earlier stay encoded at the old version in etcd, and
# the CRD records this in status.storedVersions. If a later chart release
# removes the old version from spec.versions while it is still listed in
# storedVersions, the API server rejects the CRD update and the Helm upgrade
# fails. Re-writing every object through the API server re-encodes it at the
# current storage version, which is the same approach as
# kube-storage-version-migrator, and needs no etcd access.
#
# A no-op PUT only reaches etcd when the stored bytes differ from the newly
# encoded ones, so objects already at the storage version are not written
# again: no resourceVersion bump, no generation change, no ESO re-sync, no
# Argo CD drift.
#
# Usage:
#   migrate-eso-stored-versions.sh --context <name> [--list | --apply] [--crd <name>]
#
# Examples:
#   scripts/migrate-eso-stored-versions.sh --context govuk-integration           # dry run (default)
#   scripts/migrate-eso-stored-versions.sh --context govuk-integration --list    # read-only report
#   scripts/migrate-eso-stored-versions.sh --context govuk-integration --crd externalsecrets.external-secrets.io
#   scripts/migrate-eso-stored-versions.sh --context govuk-integration --apply   # make changes
#
#   With AWS credentials from gds-cli:
#   gds aws govuk-integration-platformengineer -- scripts/migrate-eso-stored-versions.sh --context govuk-integration
#
# Options:
#   --context <name>  Required. The kubeconfig context to run against, e.g.
#                     govuk-integration, govuk-staging or govuk-prod. Every
#                     kubectl call uses it explicitly, so your current
#                     context is ignored. There is no default, so you always
#                     name the cluster you are changing.
#
#   (no mode flag)    Dry run, the default. Reports each CRD as OK or STALE,
#                     then re-submits every object under a STALE CRD with
#                     kubectl replace --dry-run=server. Admission webhooks
#                     (ESO's and Gatekeeper's) check each object, but nothing
#                     is saved and storedVersions is not changed. Rejected
#                     objects are reported as FAILED.
#
#   --list            Read-only report. Prints each CRD as OK or STALE, and
#                     lists the objects under each STALE CRD as
#                     namespace/name (just name if cluster-scoped). Sends no
#                     update requests at all, not even dry-run ones. Object
#                     names go to stdout and everything else to stderr, so
#                     `--list > objects.txt` captures just the names. Cannot
#                     be combined with --apply.
#
#   --apply           Makes the changes. Re-saves every object under each
#                     STALE CRD, making up to MAX_RETRIES attempts in total
#                     per object if ESO's status updates cause a conflict.
#                     Once every object for a CRD has succeeded, it sets
#                     that CRD's status.storedVersions to just the storage
#                     version. If any object fails, that CRD's
#                     storedVersions is left unchanged and the script moves
#                     on to the next CRD. Safe to re-run. Cannot be combined
#                     with --list.
#
#   --crd <name>      Limit the run to one CRD, using its full name, e.g.
#                     externalsecrets.external-secrets.io. Works in any mode.
#                     Exits with an error if that CRD doesn't exist in the
#                     cluster. Without it, every CRD in the
#                     external-secrets.io and *.external-secrets.io groups is
#                     processed.
#
#   -h, --help        Print this help and exit.
#
# Output: progress goes to stderr. Each CRD is reported as OK (storedVersions
# already matches the storage version) or STALE, followed by a summary line.
#
# Exit status: 0 on success, including when nothing needed migrating. 1 if
# any object failed, if the arguments are invalid, or if the cluster can't be
# reached.
#
# Required RBAC: get/list/update on all *.external-secrets.io resources
# cluster-wide, and patch on customresourcedefinitions/status.
# (Use platformengineer, tempadmin or fulladmin)
#
# Requires: kubectl >= 1.24 (for --subresource), jq.

set -euo pipefail

readonly MAX_RETRIES=3
readonly GROUP_REGEX='(^|\.)external-secrets\.io$'

context=""
apply=false
list_only=false
only_crd=""

usage() {
  sed -n '3,/^$/p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

log()  { printf '%s\n' "$*" >&2; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --context) context="${2:?--context needs a value}"; shift 2 ;;
    --apply)   apply=true; shift ;;
    --list)    list_only=true; shift ;;
    --crd)     only_crd="${2:?--crd needs a value}"; shift 2 ;;
    -h|--help) usage 0 ;;
    *)         log "Unknown argument: $1"; usage 1 ;;
  esac
done

[ -n "$context" ] || die "--context is required (be explicit about which cluster you are changing)"
command -v kubectl >/dev/null || die "kubectl not found"
command -v jq >/dev/null      || die "jq not found"

k() { kubectl --context "$context" "$@"; }

k version --request-timeout=10s >/dev/null 2>&1 \
  || die "Cannot reach cluster for context '$context' (credentials expired?)"

if $apply && $list_only; then
  die "--apply and --list are mutually exclusive"
fi

if $list_only; then
  log "Mode: LIST (read-only) against context '$context'"
elif $apply; then
  log "Mode: APPLY against context '$context'"
else
  log "Mode: DRY RUN against context '$context' (pass --apply to make changes)"
fi

# Re-write one object through the API server. Retries on optimistic-lock
# conflicts, which ESO's own status updates can cause.
#   $1 = fully-qualified resource (plural.version.group)
#   $2 = namespace (empty for cluster-scoped)
#   $3 = name
rewrite_object() {
  local resource="$1" ns="$2" name="$3"
  local ns_args=() dry_args=() attempt=1 out

  [ -n "$ns" ] && ns_args=(-n "$ns")
  $apply || dry_args=(--dry-run=server)

  while [ "$attempt" -le "$MAX_RETRIES" ]; do
    # Fetch fresh each attempt so resourceVersion is current.
    if out=$(k get "$resource" "${ns_args[@]+"${ns_args[@]}"}" "$name" -o json 2>&1 \
              | k replace "${dry_args[@]+"${dry_args[@]}"}" -f - 2>&1); then
      return 0
    fi
    case "$out" in
      *"the object has been modified"*|*Conflict*)
        attempt=$((attempt + 1)); sleep 1 ;;
      *NotFound*|*"not found"*)
        # Deleted while we were working; nothing left to migrate.
        return 0 ;;
      *)
        log "    FAILED ${ns:+$ns/}$name: $out"; return 1 ;;
    esac
  done
  log "    FAILED ${ns:+$ns/}$name: still conflicting after $MAX_RETRIES attempts"
  return 1
}

crds=$(k get crd -o json \
  | jq -r --arg re "$GROUP_REGEX" '.items[] | select(.spec.group | test($re)) | .metadata.name' \
  | sort)

[ -n "$crds" ] || die "No external-secrets.io CRDs found in context '$context'"

if [ -n "$only_crd" ]; then
  printf '%s\n' "$crds" | grep -qx "$only_crd" || die "CRD '$only_crd' not found"
  crds="$only_crd"
fi

total_failed=0
needs_migration=0

for crd in $crds; do
  crd_json=$(k get crd "$crd" -o json)
  storage=$(jq -r '.spec.versions[] | select(.storage) | .name' <<<"$crd_json")
  stored=$(jq -c '.status.storedVersions // []' <<<"$crd_json")
  plural=$(jq -r '.spec.names.plural' <<<"$crd_json")
  group=$(jq -r '.spec.group' <<<"$crd_json")
  resource="${plural}.${storage}.${group}"

  if [ "$stored" = "[\"$storage\"]" ]; then
    log "OK    $crd storedVersions=$stored"
    continue
  fi

  needs_migration=$((needs_migration + 1))
  log "STALE $crd storedVersions=$stored storage=$storage"

  objects=$(k get "$resource" -A -o json \
    | jq -r '.items[] | [(.metadata.namespace // ""), .metadata.name] | @tsv')
  count=$(printf '%s' "$objects" | grep -c . || true)
  log "    $count object(s) to re-write"

  if $list_only; then
    while IFS=$'\t' read -r ns name; do
      [ -n "$name" ] || continue
      printf '    %s\n' "${ns:+$ns/}$name"
    done <<<"$objects"
    continue
  fi

  crd_failed=0
  while IFS=$'\t' read -r ns name; do
    [ -n "$name" ] || continue
    rewrite_object "$resource" "$ns" "$name" || crd_failed=$((crd_failed + 1))
  done <<<"$objects"

  if [ "$crd_failed" -gt 0 ]; then
    warn "$crd: $crd_failed object(s) failed; leaving storedVersions untouched"
    total_failed=$((total_failed + crd_failed))
    continue
  fi

  if $apply; then
    k patch crd "$crd" --subresource=status --type=merge \
      -p "{\"status\":{\"storedVersions\":[\"$storage\"]}}" >/dev/null
    new_stored=$(k get crd "$crd" -o jsonpath='{.status.storedVersions}')
    log "    storedVersions now $new_stored"
  else
    log "    would set storedVersions to [\"$storage\"]"
  fi
done

log ""
log "CRDs needing migration: $needs_migration; object failures: $total_failed"
[ "$total_failed" -eq 0 ]

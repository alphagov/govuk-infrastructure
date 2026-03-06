#!/bin/bash
set -euo pipefail

NAMESPACE="jobrequest-system"
SERVICE="jobrequest-webhook"
TMPDIR=$(mktemp -d)
trap 'rm -rf ${TMPDIR}' EXIT

echo "Generating self-signed TLS certificates..."

# Generate CA
openssl genrsa -out "${TMPDIR}/ca.key" 2048
openssl req -x509 -new -nodes -key "${TMPDIR}/ca.key" \
  -subj "/CN=jobrequest-webhook-ca" -days 365 -out "${TMPDIR}/ca.crt"

# Generate server key + CSR
openssl genrsa -out "${TMPDIR}/server.key" 2048
openssl req -new -key "${TMPDIR}/server.key" \
  -subj "/CN=${SERVICE}.${NAMESPACE}.svc" \
  -out "${TMPDIR}/server.csr"

# Sign with CA (with SAN)
cat > "${TMPDIR}/ext.cnf" <<EOF
[v3_req]
subjectAltName = DNS:${SERVICE}.${NAMESPACE}.svc
EOF

openssl x509 -req -in "${TMPDIR}/server.csr" -CA "${TMPDIR}/ca.crt" \
  -CAkey "${TMPDIR}/ca.key" -CAcreateserial \
  -out "${TMPDIR}/server.crt" -days 365 \
  -extfile "${TMPDIR}/ext.cnf" -extensions v3_req

# Create the TLS secret
kubectl -n "${NAMESPACE}" delete secret jobrequest-webhook-tls --ignore-not-found
kubectl -n "${NAMESPACE}" create secret tls jobrequest-webhook-tls \
  --cert="${TMPDIR}/server.crt" --key="${TMPDIR}/server.key"

# Patch the caBundle into webhook configurations
CA_BUNDLE=$(base64 < "${TMPDIR}/ca.crt" | tr -d '\n')

kubectl patch mutatingwebhookconfiguration jobrequest-mutating \
  --type='json' -p="[
    {\"op\":\"replace\",\"path\":\"/webhooks/0/clientConfig/caBundle\",\"value\":\"${CA_BUNDLE}\"},
    {\"op\":\"replace\",\"path\":\"/webhooks/1/clientConfig/caBundle\",\"value\":\"${CA_BUNDLE}\"}
  ]"

kubectl patch validatingwebhookconfiguration jobrequest-validating \
  --type='json' -p="[
    {\"op\":\"replace\",\"path\":\"/webhooks/0/clientConfig/caBundle\",\"value\":\"${CA_BUNDLE}\"}
  ]"

echo "TLS certificates generated and webhook configurations patched."

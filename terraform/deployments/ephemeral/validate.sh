#!/usr/bin/env bash
set -euo pipefail

function usage {
  echo "Usage:"
  echo "  $0 <cluster-name>"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

REQUIRED_TOOLS=(
  aws
  jq
  kubectl
)

for TOOL in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$TOOL" >>/dev/null 2>&1; then
    echo "Command $TOOL is not available, but is required to run this validator"
    exit 1
  fi
done

export CLUSTER_NAME=$1
if [ -z "$CLUSTER_NAME" ]; then
  echo "The cluster name must be given as the first argument" >&2
  exit 1
fi

if ! aws eks describe-cluster --name "$CLUSTER_NAME" >/dev/null 2>&1; then
  >&2 echo "The cluster $CLUSTER_NAME was not found in AWS, or you are not authenticated with AWS." 
  exit 1
fi

echo "Cluster name: ${CLUSTER_NAME}" >&2
echo "Assuming your shell has access to the ephemeral cluster" >&2

SECRETS_MANAGER_SECRET_NAME="govuk/ephemeral/${CLUSTER_NAME}/validator-external-secret-$(date +%s)" # pragma: allowlist secret
echo "Creating secrets manager secret $SECRETS_MANAGER_SECRET_NAME"
aws secretsmanager create-secret \
  --name "$SECRETS_MANAGER_SECRET_NAME" \
  --description 'Secret created/updated/used by the ephemeral-cluster-valdator script' \
  --secret-string '{"testSecretKey": "testSecretValueInitial"}' >> /dev/null # pragma: allowlist secret

MANIFEST="$(cat <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ephemeral-cluster-validator
  annotations:
    kubernetes.io/description: Secret created/updated/used by the ephemeral-cluster-valdator script
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secretsmanager
    kind: ClusterSecretStore
  target:
    deletionPolicy: Delete
    name: ephemeral-cluster-validator
  dataFrom:
    - extract:
        key: "$SECRETS_MANAGER_SECRET_NAME"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: ephemeral-cluster-validator
  name: ephemeral-cluster-validator
spec:
  replicas: 1
  selector:
     matchLabels:
       app: ephemeral-cluster-validator
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: ephemeral-cluster-validator
    spec:
      containers:
      - image: "nginxinc/nginx-unprivileged:latest"
        name: nginx
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
              - "ALL"
          readOnlyRootFilesystem: true
        env:
          - name: EXTERNAL_SECRET
            valueFrom:
              secretKeyRef:
                name: ephemeral-cluster-validator
                key: testSecretKey
        volumeMounts:
          - name: ephemeral-cluster-validator-tmp
            mountPath: /tmp
      securityContext:
        seccompProfile:
          type: RuntimeDefault
        fsGroup: 101
        runAsNonRoot: true
        runAsUser: 101
        runAsGroup: 101
      volumes:
      - name: ephemeral-cluster-validator-tmp
        ephemeral:
          volumeClaimTemplate:
            spec:
              accessModes:
                - ReadWriteOncePod
              storageClassName: ebs-gp3
              resources:
                requests:
                  storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: ephemeral-cluster-validator
  name: ephemeral-cluster-validator
spec:
  ports:
  - name: 8080-8080
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: ephemeral-cluster-validator
  type: NodePort
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  creationTimestamp: null
  name: ephemeral-cluster-validator
  annotations:
    alb.ingress.kubernetes.io/scheme: "internet-facing"
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: "2"
    alb.ingress.kubernetes.io/healthy-threshold-count: "2"
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: "5"
    alb.ingress.kubernetes.io/load-balancer-name: "ephemeral-cluster-validator"
spec:
  ingressClassName: aws-alb
  tls:
  - hosts:
    - "ephemeral-cluster-validator.${CLUSTER_NAME}.ephemeral.govuk.digital"
  rules:
  - host: ephemeral-cluster-validator.${CLUSTER_NAME}.ephemeral.govuk.digital
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ephemeral-cluster-validator
            port:
              number: 8080
EOF
)"

kubectl apply -f <(echo "${MANIFEST}")

function delete_validator {
  echo "Cleaning up"
  kubectl delete -f <(echo "${MANIFEST}")

  echo "Deleting secrets manager secret $SECRETS_MANAGER_SECRET_NAME"
  if aws secretsmanager delete-secret --secret-id "$SECRETS_MANAGER_SECRET_NAME" --force-delete-without-recovery >>/dev/null; then
    echo "Secrets manager secret deleted"
  else
    echo "Failed to delete secrets manager secret, see error from aws cli above"
  fi
}

function validate_external_secret_value {
  local EXPECTED_SECRET_VALUE="$1"

  if ! INITIAL_SECRET_VALUE_JSON=$(kubectl get secret ephemeral-cluster-validator -o json); then
    >&2 echo "Secret ephemeral-cluster-validator has not been provisioned by the configured external secret"
    return 1
  fi
  
  if ! INITIAL_SECRET_VALUE=$(jq --raw-output <<<"$INITIAL_SECRET_VALUE_JSON" '.data.testSecretKey | @base64d'); then
    >&2 echo "Secret ephemeral-cluster-validator could not be parsed correctly by jq, or did not contain the key 'testSecretKey'"
    return 1
  fi
  
  if [ "$INITIAL_SECRET_VALUE" != "$EXPECTED_SECRET_VALUE" ]; then
    >&2 echo "The key testSecretKey of secret ephemeral-cluster-validator did not have the correct value"
    return 1
  fi
  
  return 0
}

echo "Checking that the external secret was correctly provisioned"
if ! validate_external_secret_value "testSecretValueInitial"; then # pragma: allowlist secret
  >&2 echo "Failed validation of external secret"
  delete_validator
  exit 1
fi

echo "Updating secrets manager secret $SECRETS_MANAGER_SECRET_NAME"
if ! aws secretsmanager update-secret \
  --secret-id "$SECRETS_MANAGER_SECRET_NAME" \
  --description 'Secret created/updated/used by the ephemeral-cluster-valdator script' \
  --secret-string '{"testSecretKey": "testSecretValueUpdated"}' >>/dev/null; then # pragma: allowlist secret
  >&2 echo "Failed to update secrets manager secret"
  delete_validator
  exit 1
fi

echo "Forcing resync of external secret"
if ! kubectl annotate externalsecrets.external-secrets.io ephemeral-cluster-validator force-sync="$(date +%s)" --overwrite; then
  >&2 echo "Failed to annotate the external secret to force a resync"
  delete_validator
  exit 1
fi

echo "Waiting 2 seconds to give ample time to update"
sleep 2

echo "Checking that the external secret was correctly updated"
if ! validate_external_secret_value "testSecretValueUpdated"; then # pragma: allowlist secret
  >&2 echo "Failed validation of external secret update"
  delete_validator
  exit 1
fi

START_TIME="$(date +%s)"
NOW="$(date +%s)"
SUCCESS=0

echo "Waiting up to 10 minutes for load balancer creation"
LOAD_BALANCER_ARN=
until [ -n "$LOAD_BALANCER_ARN" ]; do
  NOW="$(date +%s)"
  if [ $(( NOW - START_TIME )) -ge 600 ]; then
    >&2 echo "Waited 10 minutes, giving up and tearing down validator"
    delete_validator
    exit 1
  fi

  echo -n "."
  LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers | jq -r '.LoadBalancers[] | select(.LoadBalancerName == "ephemeral-cluster-validator") | .LoadBalancerArn')
done
echo

echo "Load balancer found, waiting for up to 10 minutes for it to be available"
if ! aws elbv2 wait load-balancer-available --load-balancer-arns "$LOAD_BALANCER_ARN"; then
  >&2 echo "Load balancer never becaome avaialble"
  delete_validator
  exit 1
fi

START_TIME="$(date +%s)"
NOW="$(date +%s)"
SUCCESS=0

echo "About to start polling until the validator is online; 10m timeout"
while [ $(( NOW - START_TIME )) -lt 600 ]; do
  if ! curl --connect-timeout 2 --fail "https://ephemeral-cluster-validator.${CLUSTER_NAME}.ephemeral.govuk.digital" >/dev/null 2>&1; then
    echo -n "."
    sleep "5s"
  else
    echo ""
    echo "Cluster validator is up and running"
    SUCCESS=1
    break
  fi

  NOW="$(date +%s)"
done

delete_validator

if [ "${SUCCESS}" -ne 1 ]; then
  echo "Cluster validation failed"
  exit 1
fi

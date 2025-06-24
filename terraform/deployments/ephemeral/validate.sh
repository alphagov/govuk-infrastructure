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

MANIFEST="$(cat <<EOF
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
       emptyDir: {}
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
}

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

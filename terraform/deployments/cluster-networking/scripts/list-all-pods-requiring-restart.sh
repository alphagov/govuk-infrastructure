#!/usr/bin/env bash

for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
     ceps=$(kubectl -n "${ns}" get cep \
         -o jsonpath='{.items[*].metadata.name}')
     pods=$(kubectl -n "${ns}" get pod \
         -o custom-columns=NAME:.metadata.name,NETWORK:.spec.hostNetwork \
         | grep -E '\s(<none>|false)' | awk '{print $1}' | tr '\n' ' ')
     ncep=$(echo "${pods} ${ceps}" | tr ' ' '\n' | sort | uniq -u | paste -s -d ' ' -)
     for pod in $(echo $ncep); do
          echo "${ns}/${pod}";
     done
done

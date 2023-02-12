#!/bin/sh

ARGO_PWD=`kubectl -n argocd get secret argocd-secret -o jsonpath="{.data.password}" | base64 -d`
argocd login --insecure --server argocd.tikaldev.click --username admin --password $ARGO_PWD --grpc-web

CONTEXT_NAME=`kubectl config view -o jsonpath='{.current-context}'`

argocd cluster add $CONTEXT_NAME
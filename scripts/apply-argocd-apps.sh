#!/bin/bash
# Apply all ArgoCD applications

echo "Applying ArgoCD applications..."

# Dev applications (auto-sync)
kubectl apply -f argocd/nova-tech-dev.yaml
kubectl apply -f argocd/bloom-cafe-dev.yaml
kubectl apply -f argocd/arclight_agency-dev.yaml
kubectl apply -f argocd/verdant_homes-dev.yaml
kubectl apply -f argocd/zenfit_studio-dev.yaml

# Staging applications (auto-sync)
kubectl apply -f argocd/nova-tech-staging.yaml
kubectl apply -f argocd/bloom-cafe-staging.yaml
kubectl apply -f argocd/arclight_agency-staging.yaml
kubectl apply -f argocd/verdant_homes-staging.yaml
kubectl apply -f argocd/zenfit_studio-staging.yaml

# Production applications (manual sync)
kubectl apply -f argocd/nova-tech-prod.yaml
kubectl apply -f argocd/bloom-cafe-prod.yaml
kubectl apply -f argocd/arclight_agency-prod.yaml
kubectl apply -f argocd/verdant_homes-prod.yaml
kubectl apply -f argocd/zenfit_studio-prod.yaml

echo "All ArgoCD applications applied!"
echo ""
echo "Check status with: argocd app list"
echo "Sync production apps manually when ready"
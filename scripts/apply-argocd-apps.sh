#!/bin/bash
# Apply ArgoCD applications for staging and production (no dev since we don't build dev images)

echo "Applying ArgoCD applications..."

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
echo "Staging apps will auto-sync when you merge dev→staging"
echo "Production apps require manual sync after staging→main merge"
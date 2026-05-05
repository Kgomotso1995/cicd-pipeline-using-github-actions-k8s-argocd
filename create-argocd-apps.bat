@echo off
setlocal enabledelayedexpansion

set "apps=zenfit_studio arclight_agency verdant_homes"
set "envs=dev staging prod"

for %%a in (%apps%) do (
    for %%e in (%envs%) do (
        set "namespace=default"
        set "branch=dev"
        set "deployment_file=deployment-dev.yaml"

        if "%%e"=="staging" (
            set "namespace=staging"
            set "branch=staging"
            set "deployment_file=deployment-staging.yaml"
        )
        if "%%e"=="prod" (
            set "namespace=production"
            set "branch=main"
            set "deployment_file=deployment-main.yaml"
        )

        set "sync_policy=automated:"
        set "prune=      prune: true"
        set "selfheal=      selfHeal: true"
        if "%%e"=="prod" (
            set "sync_policy=automated: null  # Manual sync for production"
            set "prune="
            set "selfheal="
        )

        (
            echo apiVersion: argoproj.io/v1alpha1
            echo kind: Application
            echo metadata:
            echo   name: %%a-%%e
            echo   namespace: argocd
            echo   labels:
            echo     env: %%e
            echo spec:
            echo   project: default
            echo   source:
            echo     repoURL: https://github.com/Kgomotso1995/cicd-pipeline-using-github-actions-k8s-argocd
            echo     targetRevision: !branch!
            echo     path: apps/%%a/k8s
            echo     directory:
            echo       include: !deployment_file!
            echo   destination:
            echo     server: https://kubernetes.default.svc
            echo     namespace: !namespace!
            echo   syncPolicy:
            echo     !sync_policy!
            echo     !prune!
            echo     !selfheal!
            echo     syncOptions:
            echo       - CreateNamespace=true
        ) > "argocd\%%a-%%e.yaml"
    )
)

echo All ArgoCD applications created!
@echo off
setlocal enabledelayedexpansion

set "apps=zenfit-studio arclight-agency verdant-homes"
set "envs=dev staging main"

for %%a in (%apps%) do (
    echo Creating manifests for %%a

    REM Create service
    (
        echo apiVersion: v1
        echo kind: Service
        echo metadata:
        echo   name: %%a
        echo   namespace: sites-dev
        echo   labels:
        echo     app: %%a
        echo spec:
        echo   selector:
        echo     app: %%a
        echo   ports:
        echo     - name: http
        echo       port: 80
        echo       targetPort: 80
        echo       protocol: TCP
        echo   type: ClusterIP
    ) > "apps\%%a\k8s\service.yaml"

    REM Create deployments for each environment
    for %%e in (%envs%) do (
        set "replicas=1"
        set "namespace=sites-dev"
        set "image_tag=%%e"
        set "env_label=dev"

        if "%%e"=="staging" (
            set "replicas=2"
            set "namespace=sites-staging"
            set "env_label=staging"
        )
        if "%%e"=="main" (
            set "replicas=3"
            set "namespace=sites-prod"
            set "env_label=prod"
            set "image_tag=latest"
        )

        (
            echo apiVersion: apps/v1
            echo kind: Deployment
            echo metadata:
            echo   name: %%a
            echo   namespace: !namespace!
            echo   labels:
            echo     app: %%a
            echo     env: !env_label!
            echo spec:
            echo   replicas: !replicas!
            echo   selector:
            echo     matchLabels:
            echo       app: %%a
            echo   strategy:
            echo     type: RollingUpdate
            echo     rollingUpdate:
            echo       maxSurge: 1
            echo       maxUnavailable: 0
            echo   template:
            echo     metadata:
            echo       labels:
            echo         app: %%a
            echo         env: !env_label!
            echo     spec:
            echo       containers:
            echo         - name: %%a
            echo           image: ghcr.io/kgomotso1995/%%a:!image_tag!
            echo           imagePullPolicy: Always
            echo           ports:
            echo             - name: http
            echo               containerPort: 80
            echo               protocol: TCP
            echo           livenessProbe:
            echo             httpGet:
            echo               path: /
            echo               port: 80
            echo             initialDelaySeconds: 5
            echo             periodSeconds: 30
            echo             failureThreshold: 3
            echo           readinessProbe:
            echo             httpGet:
            echo               path: /
            echo               port: 80
            echo             initialDelaySeconds: 3
            echo             periodSeconds: 10
            echo           resources:
            echo             requests:
            echo               memory: "32Mi"
            echo               cpu: "10m"
            echo             limits:
            echo               memory: "64Mi"
            echo               cpu: "50m"
        ) > "apps\%%a\k8s\deployment-%%e.yaml"
    )
)

echo All manifests created!
# sites-gitops

Branch-based GitOps for 5 static sites across dev / staging / production on Docker Desktop Kubernetes.

---

## How it works

| Branch    | Environment | Namespace       | ArgoCD sync  | Replicas |
|-----------|-------------|-----------------|--------------|----------|
| `dev`     | Development | `sites-dev`     | Automatic    | 1        |
| `staging` | Staging     | `sites-staging` | Automatic    | 2        |
| `main`    | Production  | `sites-prod`    | **Manual**   | 3        |

The branch **is** the environment. Each branch holds the k8s manifests with the right namespace and image tag already baked in. GitHub Actions builds a new image on every push, patches the `deployment.yaml` on that branch with the pinned SHA tag, and commits it back. ArgoCD watches the branch and syncs the cluster.

---

## Repo structure

```
sites-gitops/
├── apps/
│   ├── nova-tech/
│   │   ├── index.html          ← site source
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   └── k8s/
│   │       ├── deployment.yaml ← namespace + image tag match this branch
│   │       └── service.yaml
│   ├── bloom-cafe/   (same layout)
│   ├── zenfit-studio/
│   ├── arclight-agency/
│   └── verdant-homes/
│
├── argocd/
│   ├── sites-dev.yaml      ← watches dev branch
│   ├── sites-staging.yaml  ← watches staging branch
│   └── sites-prod.yaml     ← watches main branch
│
├── scripts/
│   ├── init-branches.sh    ← run ONCE after creating the repo
│   ├── promote.sh          ← dev→staging or staging→main
│   └── port-forward-all.sh ← open all 5 sites locally
│
└── .github/workflows/
    └── ci-cd.yaml          ← build image → patch manifest → commit
```

---

## First-time setup

### 1. Create the repo and push

```bash
mkdir sites-gitops && cd sites-gitops
git init -b main
# copy all files from the zip into this folder
git add .
git commit -m "initial commit"
gh repo create sites-gitops --private --source=. --remote=origin --push
```

### 2. Run the branch initialiser

```bash
chmod +x scripts/*.sh
./scripts/init-branches.sh YOUR_GITHUB_USERNAME
```

This creates the `staging` and `dev` branches, patches each branch's manifests with the correct namespace/tag/replicas, and applies all three ArgoCD Application manifests.

### 3. Set up GitHub Environments (optional but recommended)

Repo → Settings → Environments:
- `development` — no protection, branch: `dev`
- `staging` — 1 required reviewer, branch: `staging`
- `production` — 2 required reviewers, 10-min wait timer, branch: `main`

### 4. Add the GITOPS_PAT secret

GitHub → Settings → Developer settings → Fine-grained PAT → Contents: read+write on this repo

```bash
gh secret set GITOPS_PAT --body "github_pat_xxxx"
```

---

## Daily workflow

### Make a change

```bash
git checkout dev
# edit apps/nova-tech/index.html
git add . && git commit -m "feat: update hero copy"
git push origin dev
# → Actions builds nova-tech image, patches deployment.yaml, commits back
# → ArgoCD auto-syncs sites-dev within ~60 seconds
```

### View it locally

```bash
./scripts/port-forward-all.sh dev
# open http://localhost:8081 (nova-tech)
# open http://localhost:8082 (bloom-cafe)  etc.
```

### Promote to staging

```bash
./scripts/promote.sh dev
# → merges dev into staging
# → Actions triggers on staging branch, builds staging images
# → ArgoCD auto-syncs sites-staging
```

### Promote to production

```bash
./scripts/promote.sh staging
# → merges staging into main
# → Actions triggers (requires reviewer approval if GitHub Environments configured)
# → ArgoCD detects drift on sites-prod but does NOT auto-sync

# When ready to go live:
argocd app sync sites-prod
# or click Sync in https://localhost:8080
```

### Check status

```bash
argocd app list
kubectl get pods -n sites-dev
kubectl get pods -n sites-staging
kubectl get pods -n sites-prod
```

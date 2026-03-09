# DevOps Practices - QR Code Generator

Full-stack QR code generator with:
- `Client`: Next.js frontend
- `Server`: FastAPI backend
- `terraform`: Azure infrastructure as code (work in progress)
- `docker-compose.yml`: local multi-container setup

## Current status

- App foundation is in place: frontend, backend, Dockerfiles, and compose orchestration.
- Backend can generate QR codes and store them either locally or in Backblaze (S3-compatible).
- Basic backend tests exist.
- CI workflow exists, but paths and build logic need correction to match current folders.
- Terraform structure exists (bootstrap + environment + modules), but several modules are incomplete.

## Project structure

```text
DevOps_practices/
  Client/                      # Next.js app
  Server/                      # FastAPI API
  terraform/
    bootstrap/                 # Remote state infrastructure
    environments/dev/          # Environment wiring
    modules/                   # ACR/AKS/Key Vault/Monitoring modules (partial)
  docker-compose.yml
```

## Quick start (local)

1. Configure environment variables:
   - Copy `Server/.env.example` to `Server/.env`
   - Fill values only if you want cloud object storage

2. Run the stack:

```bash
docker compose up --build
```

3. Open:
- Frontend: `http://localhost:3000`
- Backend docs: `http://localhost:8000/docs`

## Backend tests

```bash
cd Server
pytest -q
```

If cloud storage variables are set, tests may try external network access. For local-only tests, leave S3/Backblaze variables empty.

## Infrastructure notes

- `terraform/bootstrap` sets up remote state storage.
- `terraform/environments/dev` wires resource group + modules.
- `modules/acr`, `modules/keyvault`, and `modules/monitoring` are not complete yet.
- `modules/aks` is present but still missing module variable/output definitions.

## Next priorities

1. Finish Terraform modules and run `terraform validate/plan` end-to-end.
2. Fix CI paths (`api` -> `Server`) and separate frontend/backend image builds.
3. Stabilize tests by isolating external storage in test configuration.

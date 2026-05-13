# RER - Infrastructure Documentation

Documentation for RER Kubernetes infrastructure and deployment.

## Structure

- `kubernetes/` - Kubernetes deployment documentation
- `deployment/` - Deployment guides and strategies
- `architecture/` - Infrastructure architecture

## Quick Links

- [Kubernetes Strategy](kubernetes/KUBERNETES-STRATEGY.md)
- [Infrastructure Plan](kubernetes/INFRA-NP-PLAN.md)
- [Deployment Progress](deployment/PROGRESS.md)

## Environments

| Environment | Namespace | Cluster | Status |
|-------------|-----------|---------|--------|
| **DEV** | dev-car-dpg | cce-sp-ctn02-np | 🟢 Active |
| **HML** | hom-car-dpg | cce-sp-ctn02-np | 🟡 In Progress |
| **PRD** | prd-car-dpg | cce-sp-ctn01-p | 🔴 Planned |

## Repository Structure

```
infra-np/                    # Kubernetes descriptors
├── base/                    # Base manifests
│   ├── gateway/
│   ├── core-backend/
│   ├── core-frontend/
│   ├── authentication/
│   └── ...
└── env/                     # Environment overlays
    ├── dev/
    ├── hml/
    └── prd/
```

## Related Repositories

- **infra-np**: Kubernetes descriptors (this workspace)
- **github**: Public source code repository
- **inovacao**: Internal GitLab repository

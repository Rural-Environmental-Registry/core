# 📚 RER-DPG Documentation

Welcome to the RER documentation hub. Here you'll find all the resources to understand, deploy, and contribute to the project.

---

## 🌍 Languages / Idiomas

- [🇧🇷 Português (Brasil)](#português-brasil)
- [🇺🇸 English](#english)

---

## 🇧🇷 Português (Brasil)

### 📖 Manuais do Usuário

- **[Manual do Usuário - Módulo Cadastro (PDF)](./CAR%20DPG%20-%20Manual%20de%20Usuário%20-%20Modulo%20Cadastro%20Propriedade%20Rural%20-%20PT-BR.pdf)** - Manual completo em PDF
- [Manual do Usuário - Módulo Cadastro (Web)](./pt-br/user-manual.md) - Versão web navegável *(em desenvolvimento)*

### 🚀 Guias de Início Rápido

- [Instalação e Configuração](../readme.md#instalação)
- [Arquitetura do Sistema](../readme.md#arquitetura-do-sistema)
- [Solução de Problemas](../readme.md#solução-de-problemas)

### 📋 Documentação Técnica

- [Estrutura do Projeto](../readme.md#organização-do-projeto)
- [Configurações do Sistema](../readme.md#visualização-de-configurações-do-sistema)
- [Submódulos](./pt-br/submodules.md) *(em desenvolvimento)*

### 🔧 Componentes

- [Core Backend](../backend/README.md)
- [Core Frontend](../frontend/README.md)
- [Authentication](../authentication/README.md)
- [Calculation Engine](../calc_engine/docs/README.md)
- [Gateway](../gateway/README.md)
- [Map Component](../map_component/README.md)

---

## 🇺🇸 English

### 📖 User Manuals

- **[User Manual - Property Registration Module (PDF)](./CAR%20DPG%20-%20Manual%20de%20Usuário%20-%20Modulo%20Cadastro%20Propriedade%20Rural%20-%20EN.pdf)** - Complete PDF manual
- [User Manual - Property Registration Module (Web)](./en/user-manual.md) - Browsable web version *(under development)*

### 🚀 Quick Start Guides

- [Installation and Setup](../readme.en.md#installation)
- [System Architecture](../readme.en.md#system-architecture)
- [Troubleshooting](../readme.en.md#troubleshooting)

### 📋 Technical Documentation

- [Project Structure](../readme.en.md#project-organization)
- [System Configuration](../readme.en.md#installation)
- [Submodules](./en/submodules.md) *(under development)*

### 🔧 Components

- [Core Backend](../backend/README.md)
- [Core Frontend](../frontend/README.md)
- [Authentication](../authentication/README.md)
- [Calculation Engine](../calc_engine/docs/README.md)
- [Gateway](../gateway/README.md)
- [Map Component](../map_component/README.md)

---

## 🤝 Contributing to Documentation

We welcome contributions to improve our documentation! Here's how you can help:

### For PDF Manuals

The original PDF manuals are maintained for reference and download. If you find issues:

1. Open an issue describing the problem
2. Suggest corrections or improvements
3. We'll update the source documents

### For Web Documentation

We're converting PDF manuals to Markdown for better collaboration:

1. **Fork** the repository
2. **Edit** Markdown files in `docs/en/` or `docs/pt-br/`
3. **Submit** a Pull Request with your improvements

### Converting PDFs to Markdown

Want to help convert the PDF manuals to Markdown? Here's the process:

1. Extract text and images from PDFs
2. Create structured Markdown files in the appropriate language folder
3. Add images to `docs/assets/images/`
4. Update links in this README
5. Submit a PR

**Tools that can help:**
- `pandoc` - Document converter
- `pdf2md` - PDF to Markdown converter
- Manual editing for best results

---

## 📦 Documentation Structure

```
docs/
├── README.md                          # This file - Documentation hub
├── CAR DPG - Manual (...) - EN.pdf    # English PDF manual
├── CAR DPG - Manual (...) - PT-BR.pdf # Portuguese PDF manual
├── en/                                # English web documentation
│   ├── user-manual.md                 # User manual (web version)
│   ├── installation.md                # Installation guide
│   ├── architecture.md                # Architecture details
│   └── submodules.md                  # Submodules reference
├── pt-br/                             # Portuguese web documentation
│   ├── user-manual.md                 # Manual do usuário (versão web)
│   ├── installation.md                # Guia de instalação
│   ├── architecture.md                # Detalhes da arquitetura
│   └── submodules.md                  # Referência dos submódulos
└── assets/                            # Shared assets
    └── images/                        # Documentation images
```

---

## 📝 License

This documentation is part of the RER-DPG project and is distributed under the [MIT License](../LICENSE).

---

**Maintained by the Dataprev Superintendence of Artificial Intelligence and Innovation**

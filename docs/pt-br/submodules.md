# Guia de Submódulos do RER-DPG

Referência detalhada dos submódulos Git que compõem o sistema RER-DPG.

---

## 📦 Visão Geral

O RER-DPG utiliza submódulos Git para organizar componentes independentes. Cada submódulo é um repositório separado com seu próprio ciclo de desenvolvimento.

---

## 🔧 Submódulos Principais

### Core Backend
- **Repositório:** `backend/`
- **Tecnologia:** Spring Boot + PostgreSQL + PostGIS
- **Função:** API REST principal para gerenciamento de cadastros
- **Documentação:** [README](../../backend/README.md)

### Core Frontend
- **Repositório:** `frontend/`
- **Tecnologia:** Vue.js 3 + TypeScript + Vite
- **Função:** Interface web principal do sistema
- **Documentação:** [README](../../frontend/README.md)

### Authentication
- **Repositório:** `authentication/`
- **Tecnologia:** Keycloak + Vue.js + PostgreSQL
- **Função:** Sistema de autenticação e autorização SSO
- **Documentação:** [README](../../authentication/README.md)

### Calculation Engine
- **Repositório:** `calc_engine/`
- **Tecnologia:** Spring Boot + PostGIS
- **Função:** Motor de cálculos geoespaciais
- **Documentação:** [README](../../calc_engine/README.md)

### Gateway
- **Repositório:** `gateway/`
- **Tecnologia:** Spring Cloud Gateway
- **Função:** API Gateway para roteamento de requisições
- **Documentação:** [README](../../gateway/README.md)

### Map Component
- **Repositório:** `map_component/`
- **Tecnologia:** Vue.js 3 + Leaflet + TypeScript
- **Função:** Componente de mapa reutilizável
- **Documentação:** [README](../../map_component/README.md)

---

## 🛠️ Trabalhando com Submódulos

### Clonar com Submódulos

```bash
git clone --recurse-submodules https://github.com/seu-usuario/rer-github.git
```

### Atualizar Submódulos

```bash
# Atualizar todos
git submodule update --init --recursive

# Atualizar para última versão
git submodule update --remote --merge
```

### Fazer Alterações em Submódulo

```bash
# Entrar no submódulo
cd backend/

# Criar branch
git checkout -b feature/nova-funcionalidade

# Fazer commits
git add .
git commit -m "Adiciona nova funcionalidade"

# Push para o repositório do submódulo
git push origin feature/nova-funcionalidade

# Voltar ao projeto principal e atualizar referência
cd ..
git add backend/
git commit -m "Atualiza referência do backend"
```

### Verificar Status dos Submódulos

```bash
git submodule status
```

---

## 📚 Recursos Adicionais

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Estrutura do Projeto](../../readme.md#organização-do-projeto)
- [Arquitetura do Sistema](../../readme.md#arquitetura-do-sistema)

---

**Voltar para:** [Documentação Principal](../README.md)

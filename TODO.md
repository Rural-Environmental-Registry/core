# TODO - Melhorias e Refatorações

## Gateway - Análise e Recomendação de Substituição

### Situação Atual
O submódulo `gateway` implementa apenas funcionalidades básicas de proxy reverso usando Spring Cloud Gateway, com utilidade limitada além do roteamento simples.

### Funcionalidades Implementadas
- ✅ Proxy reverso básico (roteamento por path)
- ✅ CORS global permissivo
- ✅ Reescrita de headers de resposta
- ✅ Configuração opcional de proxy HTTP
- ✅ Dependência de Circuit Breaker (não configurada)

### Limitações Críticas
- ❌ Sem balanceamento de carga automático
- ❌ Sem autenticação ou autorização
- ❌ Sem rate limiting
- ❌ Sem métricas ou health checks
- ❌ Configuração de rotas estática
- ❌ Sem service discovery
- ❌ Overhead desnecessário de aplicação Java

### Recomendação: SUBSTITUIR

**Opção 1 - Kubernetes (Recomendada)**
- Substituir por Ingress Controller (Nginx, Traefik, HAProxy)
- Configuração declarativa via manifests K8s
- Recursos nativos: SSL termination, load balancing, rate limiting

**Opção 2 - Docker Compose**
- Substituir por Nginx como proxy reverso
- Configuração mais simples e eficiente
- Menor consumo de recursos

### Benefícios da Substituição
- 🚀 **Performance**: Nginx é significativamente mais eficiente
- 💾 **Recursos**: Footprint muito menor que Spring Boot
- 🔧 **Simplicidade**: Menos complexidade de configuração
- 🛡️ **Maturidade**: Soluções battle-tested em produção
- ☸️ **Integração**: Nativos do ecossistema Kubernetes

### Ações Necessárias
1. [ ] Criar configuração Nginx/Ingress equivalente
2. [ ] Migrar rotas do `application.yml` para nova configuração
3. [ ] Testar roteamento de todos os microsserviços
4. [ ] Atualizar docker-compose.yml/manifests K8s
5. [ ] Remover submódulo gateway
6. [ ] Atualizar documentação

### Impacto
- **Risco**: Baixo (funcionalidade simples)
- **Esforço**: Médio (reconfiguração de rotas)
- **Benefício**: Alto (performance + simplicidade)

---

## Calc Engine - Conversão para Pacote Maven

### Situação Atual
O `calc_engine` é um microsserviço Spring Boot que executa operações PostGIS através de workflows configuráveis. Tem potencial para ser convertido em biblioteca reutilizável.

### Análise de Viabilidade para Pacote Maven

**✅ Pontos Favoráveis:**
- **Funcionalidade Bem Definida**: Engine de cálculos geoespaciais com escopo claro
- **Baixo Acoplamento**: Usa apenas PostGIS e R2DBC, sem dependências específicas do domínio
- **Reutilização**: Pode ser útil para outros projetos governamentais com necessidades geoespaciais
- **Arquitetura Limpa**: Separação clara entre modelos, serviços e controladores
- **Testes Abrangentes**: Boa cobertura de testes unitários

**❌ Desafios Identificados:**
- **Dependência de Banco**: Requer PostgreSQL + PostGIS configurado
- **Configuração Complexa**: Necessita de duas bases de dados (config + cálculos)
- **Spring Boot Específico**: Fortemente acoplado ao ecossistema Spring
- **Workflows Dinâmicos**: Lógica de execução complexa para biblioteca

### Recomendação: CONVERSÃO PARCIAL

**Estratégia Sugerida:**
1. **Extrair Core Library**: Criar `rer-geospatial-core` com:
   - Modelos de dados (SpatialFunction, Workflow, etc.)
   - Interfaces de serviços
   - Utilitários de geometria (WKT, GeoJSON)
   - Validadores espaciais

2. **Manter Microsserviço**: Para:
   - Execução de workflows
   - APIs REST
   - Gerenciamento de configuração

**Benefícios:**
- 📦 **Reutilização**: Outros projetos podem usar apenas o core
- 🔧 **Flexibilidade**: Implementações customizadas possíveis
- 🚀 **Evolução**: Microsserviço mantém funcionalidades avançadas

---

## Backend - Otimizações Identificadas

### Problemas de Performance

**1. Dependências Conflitantes**
- ❌ Spring Data JPA + R2DBC juntos (overhead desnecessário)
- ❌ Versões inconsistentes (Spring Boot 3.4.2 vs Actuator 2.7.10)
- ❌ Jackson múltiplas versões

**2. Configuração Subótima**
- ❌ Sem connection pooling configurado
- ❌ Flyway sem otimizações
- ❌ JasperReports compilação em runtime

### Otimizações Recomendadas

**Dependências:**
```gradle
// REMOVER (escolher apenas uma abordagem)
- implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
- implementation 'org.springframework.boot:spring-boot-starter-data-jdbc'

// MANTER (se escolher reativo)
+ implementation 'org.springframework.boot:spring-boot-starter-data-r2dbc'

// CORRIGIR versões
- implementation 'org.springframework.boot:spring-boot-starter-actuator:2.7.10'
+ // Usar versão do parent (3.4.2)
```

**Performance:**
- ✅ Implementar cache Redis para consultas frequentes
- ✅ Otimizar queries JPA com @Query customizadas
- ✅ Configurar connection pool adequado
- ✅ Implementar paginação reativa
- ✅ Compilar JasperReports em build-time

**Arquitetura:**
- ✅ Separar DTOs de entidades JPA
- ✅ Implementar padrão CQRS para operações complexas
- ✅ Adicionar métricas customizadas
- ✅ Implementar health checks específicos

---

## Otimizações Gerais Java

### Padronização de Versões
- **Java**: Unificar em Java 21 (calc_engine e backend)
- **Spring Boot**: Padronizar em 3.4.3
- **Dependências**: Usar BOM para versionamento consistente

### Melhorias de Build
- **Multi-module**: Considerar projeto Maven/Gradle multi-módulo
- **Docker**: Otimizar Dockerfiles com multi-stage builds
- **CI/CD**: Implementar pipeline com testes automatizados

### Segurança
- **Dependências**: Atualizar bibliotecas com vulnerabilidades
- **OWASP**: Implementar verificações de segurança
- **Secrets**: Externalizar configurações sensíveis

---

## Plano de Ação Priorizado

### Fase 1 - Correções Críticas (1-2 semanas)
1. [ ] Corrigir conflitos de dependências no backend
2. [ ] Atualizar versões com vulnerabilidades
3. [ ] Implementar health checks adequados
4. [ ] Otimizar Dockerfiles

### Fase 2 - Otimizações (2-3 semanas)
1. [ ] Extrair biblioteca core do calc_engine
2. [ ] Implementar cache no backend
3. [ ] Otimizar queries e paginação
4. [ ] Substituir gateway por Nginx/Ingress

### Fase 3 - Melhorias Arquiteturais (3-4 semanas)
1. [ ] Publicar rer-geospatial-core no Maven Central
2. [ ] Implementar CQRS no backend
3. [ ] Configurar monitoramento avançado
4. [ ] Documentar APIs com OpenAPI 3.0

---

## CRÍTICO - Integração de Repositórios GitLab ↔ GitHub

### Situação Atual
**Problema crítico identificado**: Dois repositórios com estruturas divergentes e desenvolvimento ativo em ambos.

**GitLab (rer)**: 
- ✅ Pipeline CI/CD complexo e funcional
- ✅ Configurações de ambiente por branch
- ✅ Submódulos com mapeamento automático
- ✅ Deploy automatizado (prod/hml/dev)
- ❌ Estrutura de nomes inconsistente (PascalCase)
- ❌ Falta documentação e arquivos do GitHub

**GitHub (rer-github)**:
- ✅ Estrutura moderna (kebab-case)
- ✅ Documentação completa
- ✅ Arquivos de governança (CODE_OF_CONDUCT, etc.)
- ✅ Organização mais limpa
- ❌ Sem pipeline CI/CD
- ❌ Configurações incompletas

### Estratégia de Migração Recomendada

#### Fase 1 - Preparação (1 semana)

**1.1 Backup e Análise**
```bash
# Criar backup completo do GitLab
git clone --mirror <gitlab-url> rer-gitlab-backup

# Análise de diferenças críticas
diff -r --brief rer rer-github > diferenças.txt
git log --oneline --since="1 month ago" # Commits recentes em ambos
```

**1.2 Mapeamento de Estruturas**
```
GitLab → GitHub
├── Authentication/ → authentication/
├── Core-Backend/ → backend/
├── Core-Frontend/ → frontend/
├── Calculation-Engine/ → calc_engine/
├── Gateway/ → gateway/
└── Map-Component/ → map_component/
```

#### Fase 2 - Migração Incremental (2-3 semanas)

**2.1 Migrar Pipeline CI/CD**
- [ ] Converter `.gitlab-ci.yml` para GitHub Actions
- [ ] Migrar secrets e variáveis de ambiente
- [ ] Configurar runners/environments no GitHub
- [ ] Testar pipeline em branch separada

**2.2 Sincronizar Conteúdo**
```bash
# Script de sincronização
#!/bin/bash
for module in authentication backend frontend calc_engine gateway; do
    echo "Sincronizando $module..."
    rsync -av --exclude='.git' rer/$(to_pascal_case $module)/ rer-github/$module/
done
```

**2.3 Migrar Configurações**
- [ ] Adaptar estrutura `config/` para nova nomenclatura
- [ ] Atualizar templates de environment
- [ ] Migrar configurações Docker/K8s
- [ ] Validar variáveis de ambiente

#### Fase 3 - Transição (1-2 semanas)

**3.1 Período de Sincronização Bidirecional**
```yaml
# GitHub Action para sync com GitLab
name: Sync with GitLab
on:
  push:
    branches: [main, develop, staging]
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Mirror to GitLab
        run: |
          git push --mirror ${{ secrets.GITLAB_REPO_URL }}
```

**3.2 Comunicação com Time**
- [ ] Notificar equipe sobre migração
- [ ] Documentar novos processos
- [ ] Treinar time no GitHub
- [ ] Estabelecer período de transição

#### Fase 4 - Finalização (1 semana)

**4.1 Desativação do GitLab**
- [ ] Redirecionar CI/CD para GitHub
- [ ] Arquivar repositório GitLab
- [ ] Atualizar documentação
- [ ] Comunicar mudança final

### Proposta de Estrutura Final GitHub

```
rer/ (GitHub como principal)
├── .github/
│   ├── workflows/           # GitHub Actions
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── authentication/          # Ex: Authentication/
├── backend/                 # Ex: Core-Backend/
├── frontend/                # Ex: Core-Frontend/
├── calc_engine/            # Ex: Calculation-Engine/
├── gateway/                # Ex: Gateway/
├── map_component/          # Ex: Map-Component/
├── config/                 # Configurações centralizadas
├── docs/                   # Documentação
├── scripts/                # Scripts de automação
├── .env.example
├── docker-compose.yml
├── README.md
└── TODO.md
```

### GitHub Actions Pipeline

```yaml
name: RER CI/CD
on:
  push:
    branches: [main, develop, staging]
  pull_request:
    branches: [main, develop]

jobs:
  prepare:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
      - name: Setup Environment
        run: |
          cp config/environments/${{ github.ref_name }}.env .env
          ./scripts/prepare-deployment.sh
  
  test:
    needs: prepare
    strategy:
      matrix:
        module: [backend, frontend, calc_engine, authentication]
    runs-on: ubuntu-latest
    steps:
      - name: Test ${{ matrix.module }}
        run: ./scripts/test-module.sh ${{ matrix.module }}
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build Images
        run: docker compose build
  
  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to Production
        run: ./scripts/deploy.sh production
```

### Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|----------|
| Perda de histórico | Baixa | Alto | Backup completo + migração de commits |
| Quebra de CI/CD | Média | Alto | Testes em ambiente isolado |
| Conflitos de merge | Alta | Médio | Período de freeze + comunicação |
| Resistência da equipe | Média | Médio | Treinamento + documentação |

### Cronograma Detalhado

**Semana 1**: Análise e preparação
- [ ] Backup repositórios
- [ ] Mapear diferenças
- [ ] Planejar migração

**Semana 2-3**: Migração técnica
- [ ] Converter CI/CD
- [ ] Sincronizar código
- [ ] Testar pipeline

**Semana 4**: Transição
- [ ] Período de sync bidirecional
- [ ] Treinamento equipe
- [ ] Validação final

**Semana 5**: Finalização
- [ ] Switch definitivo
- [ ] Arquivar GitLab
- [ ] Documentar processo

### Benefícios da Migração

- 🎯 **Centralização**: Um único repositório principal
- 🚀 **Modernização**: GitHub Actions + estrutura atual
- 📚 **Documentação**: Melhor organização e visibilidade
- 🔄 **Padronização**: Nomenclatura consistente
- 🌍 **Visibilidade**: Repositório público para comunidade

---

*Análise realizada em: $(date)*
<p align="center">
  <img src="images/logo-rer-color.png" alt="RER Logo" width="300">
</p>

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.3-brightgreen.svg)](https://spring.io/projects/spring-boot) [![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://openjdk.java.net/) [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-PostGIS-blue.svg)](https://postgis.net/) [![R2DBC](https://img.shields.io/badge/R2DBC-Reactive-purple.svg)](https://r2dbc.io/) [![Vue.js](https://img.shields.io/badge/Vue.js-3-green.svg)](https://vuejs.org/) [![Docker](https://img.shields.io/badge/Docker-24+-blue.svg)](https://www.docker.com/)

## 📑 Índice

- [Bem-vindo ao RER](#bem-vindo-ao-RER)
- [Sobre o Projeto](#sobre-o-projeto)
- [Organização do Projeto](#organização-do-projeto)
- [Visualização de Configurações do Sistema](#visualização-de-configurações-do-sistema)
- [Instalação](#instalação)
- [Arquitetura do Sistema](#arquitetura-do-sistema)
- [Monitoramento e Logs](#monitoramento-e-logs)
- [Solução de Problemas](#solução-de-problemas)
- [Licença](#licença)
- [Contribuição](#contribuição)
- [Suporte](#suporte)

---

## Bem-vindo ao RER!

O **RER** (Rural Environmental Registry - Digital Public Good) é uma solução completa e moderna para o gerenciamento de cadastros ambientais rurais, desenvolvida como um bem público digital. Este projeto oferece uma arquitetura robusta e escalável para sistemas de cadastro de propriedades rurais com suporte a dados geoespaciais.

A solução é uma plataforma tecnológica que moderniza e amplia as capacidades do Cadastro Ambiental Rural (CAR) ao transformá-lo em um Digital Public Good (DPG).
Essa abordagem visa atender tanto às necessidades específicas do Brasil quanto permitir sua replicação em contextos internacionais, promovendo a interoperabilidade e flexibilidade necessárias para adaptação a diferentes legislações, exigências culturais e realidades locais.

Baseada em tecnologias de código aberto, a solução será modular, escalável e interoperável, devendo incluir:

- Um portal administrativo para configuração e gestão;
- Um portal para cadastramento de propriedades e proprietários;
- Ferramentas geoespaciais robustas.

O sistema é projetado para oferecer uma gama de funcionalidades inovadoras, sobretudo um motor geoespacial altamente eficiente que permite o processamento e análise de dados espaciais em tempo real, facilitando a visualização e a tomada de decisões em diversas áreas, como planejamento urbano e monitoramento ambiental. Esse motor, pode ser entendido como o módulo core do CAR DPG e será implementado como uma evolução do motor geoespacial atualmente utilizado pelo SICAR.

A solução terá uma capacidade multilíngue oferecendo suporte a diversos idiomas, garantindo acessibilidade global e adaptabilidade às necessidades locais dos usuários, independentemente da região. Além disso, o sistema deverá ser estruturado com base em microsserviços, o que assegura maior flexibilidade, escalabilidade e facilidade de manutenção, permitindo que cada componente funcione de maneira independente e possa ser atualizado ou substituído sem impactar o funcionamento global.

Os building blocks (blocos de construção), conceito tradicional em DPGs, possibilitam a criação de soluções personalizadas e a integração com outras plataformas, proporcionando uma abordagem modular e reutilizável, possibilitando ainda que blocos sejam substituídos por outras tecnologias mais adequadas à realidade de cada país. Por fim, a filosofia DPG pressupõe a disponibilização do sistema através da abordagem opensource (código aberto), oferecendo total transparência quanto ao que está sendo executado e permitindo que os usuários e desenvolvedores possam colaborar, personalizar e aprimorar continuamente suas funcionalidades, assegurando inovação constante e integração com a comunidade global de desenvolvedores, que deverá ser estruturada e incentivada pelo governo brasileiro.

---

## Sobre o Projeto

O RER é uma plataforma integrada que combina tecnologias modernas para fornecer um sistema completo de cadastro ambiental rural. Segue princípios de arquitetura modular/microsserviços e utiliza containers Docker para facilitar a implantação e manutenção.

**Principais características:**

- 🗺️ Suporte a dados geoespaciais com PostGIS
- 🧩 Biblioteca de mapa reutilizável com Leaflet e ferramentas de desenho
- 🔐 Sistema de autenticação robusto com Keycloak
- 🌐 Interface web moderna com Vue.js 3
- ⚡ API REST performática com Spring Boot
- 🚪 Gateway de API para roteamento inteligente
- 🧮 Motor de cálculos para processamento de dados
- 🐳 Containerização completa com Docker

Saiba mais sobre o sistema acessando nosso [ambiente de demonstração](https://rer.dataprev.gov.br).

---

## Organização do Projeto

O RER está organizado como um projeto principal com múltiplos submódulos Git, cada um responsável por uma funcionalidade específica do sistema:

### Estrutura dos Subprojetos

- [**`backend/`**](https://github.com/Rural-Environmental-Registry/backend) - Backend principal em Spring Boot com suporte a PostGIS para gerenciamento de cadastros de imóveis, pessoas e atributos relacionados. Fornece API REST completa com documentação Swagger.

- [**`frontend/`**](https://github.com/Rural-Environmental-Registry/frontend) - Interface web moderna desenvolvida em Vue.js 3 com Vite, oferecendo uma experiência de usuário responsiva e intuitiva para o cadastro e visualização de dados ambientais rurais.

- [**`map_component/`**](https://github.com/Rural-Environmental-Registry/map_component) - Biblioteca de mapa interativo para Vue 3, baseada em Leaflet, que fornece o componente `dpg-mapa` com suporte a múltiplas camadas, ferramentas de desenho e eventos.

- [**`authentication/`**](https://github.com/Rural-Environmental-Registry/authentication) - Sistema de autenticação e autorização baseado em Keycloak com PostgreSQL, incluindo frontend administrativo e backend para gerenciamento de usuários e permissões.

- [**`calc_engine/`**](https://github.com/Rural-Environmental-Registry/calc_engine) - Motor de cálculos para processamento de dados geoespaciais e análises ambientais, desenvolvido em Java com suporte a operações complexas de geoprocessamento.

- [**`Gateway/`**](https://github.com/Rural-Environmental-Registry/gateway) - Gateway de API baseado em Spring Cloud Gateway para roteamento inteligente entre os diferentes microsserviços, incluindo balanceamento de carga e configurações de proxy.

---

## Visualização de Configurações do Sistema

O RER oferece uma funcionalidade centralizada para a visualização de todas as configurações aplicadas nos diferentes submódulos do projeto. Isso proporciona grande transparência e facilita a depuração, permitindo que os administradores e desenvolvedores verifiquem rapidamente os valores de variáveis de ambiente, configurações de compilação e parâmetros definidos em diversos arquivos.

### Acesso à Página

A página de visualização pode ser acessada na interface do submódulo de **`Authentication`**.

1.  **Acesse a URL:** A aplicação de administração do `Authentication` está disponível em `http://localhost/<BASE_URL>/<AUTHENTICATION_FRONTEND_CONTEXT_PATH>`.

    > As variáveis `<BASE_URL>` e `<AUTHENTICATION_FRONTEND_CONTEXT_PATH>` são definidas nas [configurações](config/Main/environment/.env.example) do ambiente.

2.  **Faça o login** com as seguintes credenciais de administrador padrão:
    - **Usuário:** `admin-cardpg@gmail.com`
    - **Senha:** `NovaSenhaForte123!`

Após o login, a tabela de configurações será exibida.

### Como Funciona

A funcionalidade é orquestrada por alguns componentes-chave:

1.  **Interface de Exibição (`Authentication/frontend/src/views/AdminSettings.vue`)**: Uma página no frontend de `Authentication` que busca e exibe as configurações em uma tabela pesquisável.
2.  **Coleta de Dados do Frontend (`frontend/scripts/generate-config.sh`)**: Este script é executado durante o processo de build do `frontend` e coleta informações de arquivos como `.env`, `package.json`, e configurações do mapa, consolidando-as em um arquivo `config.json` que é servido estaticamente.
3.  **Endpoint de Backend (`backend/src/main/java/br/car/registration/controller/AdminController.java`)**: Expõe um endpoint (`/v1/admin/app-info`) que fornece configurações do lado do servidor, como propriedades da aplicação (`application.properties`), variáveis de ambiente e atributos padrão do sistema.
4.  **Parser de Configurações (`Authentication/frontend/src/helpers/table.ts`)**: Um helper no frontend de `Authentication` que interpreta os dados recebidos dos endpoints do frontend e backend, identificando a origem de cada configuração para exibição na interface.

### Como Modificar as Configurações

As alterações devem ser feitas diretamente nos arquivos de origem de cada submódulo. A tabela na página de administração indica o "componente" (submódulo) e a "origem" (arquivo ou mecanismo) de cada configuração.

Abaixo estão alguns exemplos práticos:

| Configuração            | Origem                      | Submódulo       | Como Alterar                                                                                                |
| :---------------------- | :-------------------------- | :-------------- | :---------------------------------------------------------------------------------------------------------- |
| `frontend_project_name` | `package.json`              | `frontend` | Altere o campo `name` no arquivo `frontend/package.json`.                                              |
| `backend_url`           | `.env`                      | `frontend` | Modifique a variável `VITE_CARDPG_URL` no arquivo `frontend/.env`.                                     |
| `linguagem_padrao`      | `src/config/languages.json` | `frontend` | Ajuste a chave `defaultlanguage` no arquivo `frontend/src/config/languages.json`.                      |
| `application_name`      | `application.properties`    | `backend`  | Altere a propriedade `spring.application.name` em `backend/src/main/resources/application.properties`. |
| `frontend_urls`         | `docker-compose.yaml`       | `backend`  | Defina a variável de ambiente `FRONTEND_URLS` no serviço correspondente.                                    |
| `fields.person`         | `database` (hardcoded)      | `backend`  | Modifique o método `getDefaultAttributes()` em `AdminController.java`.                                      |

Esta abordagem garante que cada submódulo permaneça autocontido em suas configurações, ao mesmo tempo que oferece uma visão unificada para a administração do sistema.

---

## Instalação

### Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Docker** versão 24+ ([instalação](https://docs.docker.com/engine/install/))
- **Docker Compose** versão 2.20 ou superior ([instalação](https://docs.docker.com/compose/install/linux/#install-using-the-repository))
- **Git** ([instalação](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
- **gettext** (para substituição de variáveis de ambiente):
  ```bash
  sudo apt install gettext-base
  ```
- Sistema Operacional: Linux (recomendado)

### Baixar o Projeto

1. **Clone o projeto com submódulos:**

   ```bash
   git clone --recurse-submodules https://github.com/Rural-Environmental-Registry/core.git rer
   ```

2. **Acesse o diretório do projeto:**
   ```bash
   cd rer
   ```

### Configuração

1. **Adicione seu usuário ao grupo Docker:**

   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. **Revise as configurações:**

   - Verifique e ajuste as variáveis de ambiente em:  
     `./config/Main/environment/.env.example`
   - Verifique a documentação de cada submódulo para configurações específicas, se necessário.

3. **Conceda permissão de execução ao script de inicialização:**

   ```bash
   chmod +x ./start.sh
   ```

   > Edite `start.sh` apenas se necessário.

### Execução com Docker

1. **Execute o script de inicialização:**

   ```bash
   ./start.sh
   ```

   Este script irá:

   - Preparar todas as variáveis de ambiente
   - Configurar os arquivos de cada submódulo
   - Construir e executar todos os containers Docker
   - Iniciar todos os serviços automaticamente

2. **Verifique o status dos serviços:**
   ```bash
   docker compose ps
   ```

### Acessando os Serviços

Após a execução bem-sucedida, os seguintes serviços estarão disponíveis (considerando as variáveis de ambiente definidas nas [configurações](config/Main/environment/.env.example)):

- **Frontend Principal:** http://localhost/<BASE_URL>
- **Backend API:** http://localhost/<BASE_URL>/<CORE_BACKEND_API_CONTEXT_PATH>
- **Documentação backend Swagger:** http://localhost/<BASE_URL>/<CORE_BACKEND_API_CONTEXT_PATH>/swagger-ui/index.html
- **Documentação da API:** [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md)
- **Keycloak Admin:** http://localhost/<BASE_URL>/<AUTHENTICATION_BASE_KEYCLOAK_BASE_URL>/admin
- **Frontend Administrativo:** http://localhost/<BASE_URL>/<AUTHENTICATION_FRONTEND_CONTEXT_PATH>/admin-login

### Credenciais Padrão

- **Administrador do Sistema:**

  - **Usuário:** `admin-cardpg@gmail.com`
  - **Senha:** `NovaSenhaForte123!`

- **Keycloak Admin:**
  - **Usuário:** `admin`
  - **Senha:** `admin`

---

## Arquitetura do Sistema

### Visão Geral

```
                                       ┌───────────────────────────┐
                                       │           NGINX           │
                                       │          (Proxy)          │
                                       └─────────────┬─────────────┘
                                                     │
                                       ┌─────────────▼─────────────┐
                                       │         Gateway           │
                                       │   (Spring Cloud Gateway)  │
                                       └─────────────┬─────────────┘
                                                     │
        ┌────────────────────────────────────────────┼───────────────────────────────────┐
        │                                            │                                   │
        │                                            │                                   │
┌───────▼───────────┐                    ┌───────────▼─────────┐              ┌──────────▼───────────┐
│       Core        │                    │    Autenticação     │              │   Motor de Cálculo   │
│ (Portal Cadastr.) │                    │                     │              │                      │
└───────┬───────────┘                    └──────────┬──────────┘              └──────────┬───────────┘
        │                                           │                                    │
        │                           ┌───────────────┼──────────────┐                     │
 ┌──────▼────────┐          ┌───────▼───────┐              ┌───────▼────────┐   ┌────────▼────────┐
 │ frontend │          │ Auth-Frontend │              │ Admin-Frontend │   │   Backend       │
 │ (Vue.js + TS) │───┐      │ (Vue.js + TS) │              │ (Vue.js + TS)  │   │ (Spring Boot)   │
 └──────┬────────┘   │      └───────┬───────┘              └───────┬────────┘   └────────┬────────┘
        │            │              └──────────────┬───────────────┘                     │
        │    ┌───────▼───────┐                     │                                     │
        │    │ Map Component │                     │                                     │
        │    │   (Leaflet)   │                     │                                     │
        │    └───────────────┘                     │                                     │
        │                                          │                                     │
 ┌──────▼──────────┐                       ┌───────▼────────┐                  ┌─────────▼───────────┐
 │   Backend       │                       │   Keycloak     │                  │ Banco de Dados      │
 │ (Spring Boot +  │                       │ (Auth Server)  │                  │ (PostgreSQL+PostGIS │
 │  JasperReports) │                       └───────┬────────┘                  │   Cálculos)         │
 └──────┬──────────┘                               │                           └─────────────────────┘
        │                                          │
 ┌──────▼──────────┐                     ┌─────────▼───────────┐
 │ Banco de Dados  │                     │ Banco de Dados      │
 │ PostgreSQL +    │                     │ PostgreSQL (Keycloak│
 │ PostGIS (Core)  │                     │ DB)                 │
 └─────────────────┘                     └─────────────────────┘
```

### Fluxo de Dados

1. **Usuário** → **frontend** (interface web)
2. **frontend** → **gateway** (requisições HTTP)
3. **gateway** → **microsserviços** (roteamento inteligente)
4. **authentication** ↔ **keycloak** (login/autorização)
5. **backend** ↔ **PostgreSQL** (dados de cadastro)
6. **calc_engine** → **Cálculos** (processamento geoespacial)

---

## Monitoramento e Logs

### Verificar Status dos Serviços

```bash
# Status geral
docker compose ps

# Logs de todos os serviços
docker compose logs -f

# Logs de um serviço específico
docker compose logs -f core-backend
```

### Verificar Conectividade dos Serviços

```bash
# Verificar se os serviços estão respondendo
curl -f http://localhost:8080 || echo "Gateway não está respondendo"
```

---

## Solução de Problemas

### Problemas Comuns

#### Portas em Uso

```bash
# Verificar portas em uso
sudo netstat -tlnp | grep :8080
```

#### Problemas de Permissão Docker

```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker

# Reiniciar Docker se necessário
sudo systemctl restart docker
```

#### Submódulos Não Atualizados

```bash
# Atualizar todos os submódulos
git submodule update --init --recursive

# Forçar atualização
git submodule foreach git pull origin main
```

#### Limpeza de Containers

```bash
# Parar e remover todos os containers
docker compose down -v

# Limpar imagens não utilizadas
docker system prune -a
```

---

## Notas Importantes

- **Portas Necessárias:** 80/443 (NGINX Proxy), 8080 (Gateway principal), 5432 (Postgres backend)
- **Recursos Mínimos:** 4GB RAM, 2 CPU cores, 10GB espaço em disco
- **Sistemas Suportados:** Linux (recomendado), macOS, Windows com WSL2
- **Persistência:** Volumes Docker para dados do PostgreSQL e configurações
- **Segurança:** Altere credenciais padrão em ambiente de produção
- **Submódulos:** Verifique os READMEs dos submódulos para instruções avançadas ou personalizadas

---

## Licença

Este projeto é distribuído sob a [GPL-3.0](https://github.com/Rural-Environmental-Registry/core/blob/main/LICENSE).

---

## Contribuição

Contribuições são bem-vindas! Para contribuir com o projeto:

1. Faça um _fork_ do repositório
2. Crie uma _branch_ para sua funcionalidade (`git checkout -b feature/AmazingFeature`)
3. Publique suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Envie para seu _branch_ (`git push origin feature/AmazingFeature`)
5. Abra um _Pull Request_

Ao enviar um _pull request_ ou _patch_, você afirma que é o autor do código e que concorda em licenciar sua contribuição sob os termos da Licença Pública Geral GNU v3.0 (ou posterior) deste projeto. Você também concorda em ceder os direitos autorais da sua contribuição ao Ministério da Gestão e Inovação em Serviços Públicos (MGI), titular deste projeto.

### Código de Conduta

Este projeto segue um [Código de Conduta](CODE_OF_CONDUCT.md) para garantir um ambiente acolhedor e livre de assédio para todos os colaboradores. Ao participar, espera-se que você respeite este código. Por favor, denuncie comportamentos inaceitáveis ​​através do rastreador de problemas do GitHub.

---

## Suporte

Para suporte técnico ou dúvidas sobre o projeto:

- **Documentação:** Consulte os READMEs individuais de cada submódulo
- **Issues:** Reporte problemas através do sistema de issues do GitHub

---

## Atribuições

Para suporte técnico ou dúvidas sobre o projeto, por favor, registre um _issue_.

Copyright (C) 2024 Ministério da Gestão e Inovação em Serviços Públicos (MGI), Governo do Brasil.

Este programa foi desenvolvido pela Dataprev como parte de um contrato com o Ministério da Gestão e Inovação em Serviços Públicos (MGI).

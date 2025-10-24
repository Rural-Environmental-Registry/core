# RER-DPG - Sistema de Cadastro de Imóveis Rurais

## Bem-vindo ao RER-DPG!

O **RER-DPG** (Rural Environmental Registry - Digital Public Good) é uma solução completa e moderna para o gerenciamento de cadastros ambientais rurais, desenvolvida como um bem público digital. Este projeto oferece uma arquitetura robusta e escalável para sistemas de cadastro de propriedades rurais com suporte a dados geoespaciais.

---

## Sobre o Projeto

O RER-DPG é uma plataforma integrada que combina tecnologias modernas para fornecer um sistema completo de cadastro ambiental rural. Segue princípios de arquitetura modular/microsserviços e utiliza containers Docker para facilitar a implantação e manutenção.

**Principais características:**

- 🗺️ Suporte a dados geoespaciais com PostGIS
- 🧩 Biblioteca de mapa reutilizável com Leaflet e ferramentas de desenho
- 🔐 Sistema de autenticação robusto com Keycloak
- 🌐 Interface web moderna com Vue.js 3
- ⚡ API REST performática com Spring Boot
- 🚪 Gateway de API para roteamento inteligente
- 🧮 Motor de cálculos para processamento de dados
- 🐳 Containerização completa com Docker

---

## Organização do Projeto

O RER-DPG está organizado como um projeto principal com múltiplos submódulos Git, cada um responsável por uma funcionalidade específica do sistema:

### Estrutura dos Subprojetos

- **`Core-Backend/`** - Backend principal em Spring Boot com suporte a PostGIS para gerenciamento de cadastros de imóveis, pessoas e atributos relacionados. Fornece API REST completa com documentação Swagger.

- **`Core-Frontend/`** - Interface web moderna desenvolvida em Vue.js 3 com Vite, oferecendo uma experiência de usuário responsiva e intuitiva para o cadastro e visualização de dados ambientais rurais.

- **`Map-Component/`** - Biblioteca de mapa interativo para Vue 3, baseada em Leaflet, que fornece o componente `dpg-mapa` com suporte a múltiplas camadas, ferramentas de desenho e eventos.

- **`Authentication/`** - Sistema de autenticação e autorização baseado em Keycloak com PostgreSQL, incluindo frontend administrativo e backend para gerenciamento de usuários e permissões.

- **`Calculation-Engine/`** - Motor de cálculos para processamento de dados geoespaciais e análises ambientais, desenvolvido em Java com suporte a operações complexas de geoprocessamento.

- **`Gateway/`** - Gateway de API baseado em Spring Cloud Gateway para roteamento inteligente entre os diferentes microsserviços, incluindo balanceamento de carga e configurações de proxy.

---

## Visualização de Configurações do Sistema

O RER-DPG oferece uma funcionalidade centralizada para a visualização de todas as configurações aplicadas nos diferentes submódulos do projeto. Isso proporciona grande transparência e facilita a depuração, permitindo que os administradores e desenvolvedores verifiquem rapidamente os valores de variáveis de ambiente, configurações de compilação e parâmetros definidos em diversos arquivos.

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
2.  **Coleta de Dados do Frontend (`Core-Frontend/scripts/generate-config.sh`)**: Este script é executado durante o processo de build do `Core-Frontend` e coleta informações de arquivos como `.env`, `package.json`, e configurações do mapa, consolidando-as em um arquivo `config.json` que é servido estaticamente.
3.  **Endpoint de Backend (`Core-Backend/src/main/java/br/car/registration/controller/AdminController.java`)**: Expõe um endpoint (`/v1/admin/app-info`) que fornece configurações do lado do servidor, como propriedades da aplicação (`application.properties`), variáveis de ambiente e atributos padrão do sistema.
4.  **Parser de Configurações (`Authentication/frontend/src/helpers/table.ts`)**: Um helper no frontend de `Authentication` que interpreta os dados recebidos dos endpoints do frontend e backend, identificando a origem de cada configuração para exibição na interface.

### Como Modificar as Configurações

As alterações devem ser feitas diretamente nos arquivos de origem de cada submódulo. A tabela na página de administração indica o "componente" (submódulo) e a "origem" (arquivo ou mecanismo) de cada configuração.

Abaixo estão alguns exemplos práticos:

| Configuração            | Origem                      | Submódulo       | Como Alterar                                                                                                |
| :---------------------- | :-------------------------- | :-------------- | :---------------------------------------------------------------------------------------------------------- |
| `frontend_project_name` | `package.json`              | `Core-Frontend` | Altere o campo `name` no arquivo `Core-Frontend/package.json`.                                              |
| `backend_url`           | `.env`                      | `Core-Frontend` | Modifique a variável `VITE_CARDPG_URL` no arquivo `Core-Frontend/.env`.                                     |
| `linguagem_padrao`      | `src/config/languages.json` | `Core-Frontend` | Ajuste a chave `defaultlanguage` no arquivo `Core-Frontend/src/config/languages.json`.                      |
| `application_name`      | `application.properties`    | `Core-Backend`  | Altere a propriedade `spring.application.name` em `Core-Backend/src/main/resources/application.properties`. |
| `frontend_urls`         | `docker-compose.yaml`       | `Core-Backend`  | Defina a variável de ambiente `FRONTEND_URLS` no serviço correspondente.                                    |
| `fields.person`         | `database` (hardcoded)      | `Core-Backend`  | Modifique o método `getDefaultAttributes()` em `AdminController.java`.                                      |

Esta abordagem garante que cada submódulo permaneça autocontido em suas configurações, ao mesmo tempo que oferece uma visão unificada para a administração do sistema.

---

## Instalação

### Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Docker** versão 24+ ([instalação](https://docs.docker.com/engine/install/))
- **Docker Compose** versão 2.20 ou superior ([instalação](https://docs.docker.com/compose/install/linux/#install-using-the-repository))
- **Git** ([instalação](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
- Acesso ao repositório GitLab da Dataprev (usuário e senha)
- Sistema Operacional: Linux (recomendado)

### Baixar o Projeto

1. **Clone o projeto com submódulos:**

   ```bash
   git clone --recurse-submodules https://inovacao.dataprev.gov.br/git/car-dpg/main.git Main
   ```

   > **Nota:** Você será solicitado a fornecer seu usuário e senha do GitLab para o projeto principal e cada submódulo.

2. **Acesse o diretório do projeto:**
   ```bash
   cd Main
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
- **Documentação Core-Backend Swagger:** http://localhost/<BASE_URL>/<CORE_BACKEND_API_CONTEXT_PATH>/swagger-ui/index.html
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
 │ Core-Frontend │          │ Auth-Frontend │              │ Admin-Frontend │   │   Backend       │
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

1. **Usuário** → **Core-Frontend** (interface web)
2. **Frontend** → **Gateway** (requisições HTTP)
3. **Gateway** → **Microsserviços** (roteamento inteligente)
4. **Authentication** ↔ **Keycloak** (login/autorização)
5. **Core-Backend** ↔ **PostgreSQL** (dados de cadastro)
6. **Calculation-Engine** → **Cálculos** (processamento geoespacial)

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

- **Portas Necessárias:** 80/443 (NGINX Proxy), 8080 (Gateway principal), 5432 (Postgres Core-Backend)
- **Recursos Mínimos:** 4GB RAM, 2 CPU cores, 10GB espaço em disco
- **Sistemas Suportados:** Linux (recomendado), macOS, Windows com WSL2
- **Persistência:** Volumes Docker para dados do PostgreSQL e configurações
- **Segurança:** Altere credenciais padrão em ambiente de produção
- **Submódulos:** Verifique os READMEs dos submódulos para instruções avançadas ou personalizadas

---

## Licença

Este projeto é distribuído sob a [Licença MIT](https://opensource.org/license/mit).

### O que isso significa na prática?

- ✅ **Uso gratuito** para fins públicos, privados ou comerciais
- ✅ **Permite adaptação e integração** em outras soluções
- ✅ **Incentiva colaboração e reutilização** como bem público digital
- ⚠️ O software é fornecido "como está", sem qualquer garantia
- ⚠️ Não há obrigação de publicar melhorias, mas contribuir de volta para a comunidade é fortemente encorajado

---

## Contribuição

Contribuições são bem-vindas! Para contribuir com o projeto:

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## Suporte

Para suporte técnico ou dúvidas sobre o projeto:

- **Equipe de Desenvolvimento:** Entre em contato através do GitLab da Dataprev
- **Documentação:** Consulte os READMEs individuais de cada submódulo
- **Issues:** Reporte problemas através do sistema de issues do GitLab

---

**Desenvolvido pela Superintendência de Inteligência Artificial e Inovação da Dataprev**

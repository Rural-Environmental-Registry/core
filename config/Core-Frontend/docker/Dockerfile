# ============================
# 1) Dependencies Stage
# ============================
FROM node:18-alpine AS dependencies

# Instalar pacotes necessários
RUN apk add --no-cache \
    git \
    jq

WORKDIR /app

# Copiar apenas arquivos de dependências primeiro
COPY package.json package-lock.json ./
COPY scripts/map-dependency.cjs ./scripts/

ARG GITLAB_TOKEN
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

# Configurar proxy e git antes de instalar dependências
RUN git config --global http.proxy "$HTTP_PROXY" && \
    git config --global https.proxy "$HTTPS_PROXY" && \
    git config --global no.proxy "$NO_PROXY" && \
    git config --global url."https://gitlab-ci-token:${GITLAB_TOKEN}@inovacao.dataprev.gov.br".insteadOf "https://inovacao.dataprev.gov.br"

# Instalar dependências com cache otimizado
RUN --mount=type=cache,target=/root/.npm \
    npm ci --ignore-scripts

# ============================
# 2) Process Dependencies Stage
# ============================
FROM dependencies AS deps-processed
COPY ./Map-Component /app/Map-Component
RUN node scripts/map-dependency.cjs

# ============================
# 3) Build Stage
# ============================
FROM deps-processed AS build
COPY . .
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}
RUN npm run build-only
RUN echo "$APP_VERSION" > dist/version.txt
RUN sh scripts/generate-config.sh

# ============================
# 4) Runtime Stage
# ============================
FROM nginx:alpine
COPY --from=build /app/dist/ /usr/share/nginx/html${BASE_URL}
RUN rm -f /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf

# Criar diretórios de cache e ajustar permissões
RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx && \
    chmod -R 755 /var/cache/nginx && \
    touch /tmp/nginx.pid && \
    chown nginx:nginx /tmp/nginx.pid

EXPOSE 80
USER nginx
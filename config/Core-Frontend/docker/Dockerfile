# ============================
# 1) Dependencies Stage
# ============================
FROM node:18-alpine AS dependencies

# Atualizar pacotes para corrigir CVEs e instalar necessários
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache jq

WORKDIR /app

# Copiar apenas arquivos de dependências primeiro
COPY package.json package-lock.json ./

# ============================
# 2) Process Dependencies Stage
# ============================
FROM dependencies AS deps-processed
# Pacote local referenciado em package.json como file:./map_component
COPY ./map_component ./map_component

# Instalar dependências com cache otimizado
RUN --mount=type=cache,target=/root/.npm \
    npm ci --ignore-scripts

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

# Atualizar pacotes para corrigir CVEs
RUN apk update && apk upgrade --no-cache

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

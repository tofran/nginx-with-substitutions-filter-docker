# Originally inspired on: https://gist.github.com/hermanbanken/96f0ff298c162a522ddbba44cad31081

ARG NGINX_DOCKER_IMAGE_TAG=1.29-alpine-slim
FROM nginx:${NGINX_DOCKER_IMAGE_TAG} AS builder

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    libedit-dev \
    bash \
    alpine-sdk \
    findutils \
    curl

RUN mkdir -p /usr/src \
    && wget -q "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz \
    && wget -q \
        "https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/refs/heads/master.tar.gz" \
        -O nginx_substitutions_filter.tar.gz \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && tar -zxC /usr/src -f nginx_substitutions_filter.tar.gz  \
    && rm nginx.tar.gz \
    && rm nginx_substitutions_filter.tar.gz \
    && cd "/usr/src/nginx-$NGINX_VERSION" \
    && bash -c 'set -eux && eval ./configure $(nginx -V 2>&1 | sed -n -e "s/^.*configure arguments: //p") --add-dynamic-module=/usr/src/ngx_http_substitutions_filter_module-master' \
    && make \
    && make install

FROM nginx:${NGINX_DOCKER_IMAGE_TAG}

COPY --from=builder /usr/lib/nginx/modules/ngx_http_subs_filter_module.so /usr/lib/nginx/modules/ngx_http_subs_filter_module.so

RUN sed -i '1iload_module /usr/lib/nginx/modules/ngx_http_subs_filter_module.so;\n' /etc/nginx/nginx.conf

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

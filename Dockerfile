# Based on: https://gist.github.com/hermanbanken/96f0ff298c162a522ddbba44cad31081

FROM nginx:alpine AS builder

LABEL maintainer="tofran <me@tofran.com>"

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
      alpine-sdk \
      bash \
      findutils \
      gcc \
      gd-dev \
      geoip-dev \
      libc-dev \
      libedit-dev \
      libxslt-dev \
      linux-headers \
      make \
      mercurial \
      openssl-dev \
      pcre-dev \
      perl-dev \
      zlib-dev

RUN mkdir -p /usr/src \
    && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O nginx.tar.gz \
    && wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/refs/heads/master.tar.gz -O nginx_substitutions_filter.tar.gz \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && tar -zxC /usr/src -f nginx_substitutions_filter.tar.gz  \
    && rm nginx.tar.gz \
    && rm nginx_substitutions_filter.tar.gz \
    && cd /usr/src/nginx-$NGINX_VERSION \
    \
    # TODO: Reuse the configure arguments from `nginx -V 2>&1 | sed -n -e 's/^.*configure arguments: //p'`
    #  without breaking the `--with-cc-opt='-Os -fomit-frame-pointer -g'` parameter
    && ./configure \
    --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-Os -fomit-frame-pointer -g' --with-ld-opt=-Wl,--as-needed,-O1,--sort-common \
    --add-dynamic-module=/usr/src/ngx_http_substitutions_filter_module-master \
    \ 
    && make \
    && make install

FROM nginx:alpine

COPY --from=builder /usr/lib/nginx/modules/ngx_http_subs_filter_module.so /usr/lib/nginx/modules/ngx_http_subs_filter_module.so

RUN sed -i '1iload_module /usr/lib/nginx/modules/ngx_http_subs_filter_module.so;\n' /etc/nginx/nginx.conf

EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

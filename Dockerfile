FROM alpine
MAINTAINER Pavel Litvinenko <gerasim13@gmail.com>
ENV NGINX_VERSION nginx-1.9.3
ADD http://nginx.org/download/${NGINX_VERSION}.tar.gz /tmp/src/${NGINX_VERSION}.tar.gz
RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base bash perl perl-dev
RUN cd /tmp/src && \
    tar -zxvf ${NGINX_VERSION}.tar.gz  && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_secure_link_module \
        --with-http_perl_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install
RUN apk del build-base && \
    rm -rf /tmp/src && \
    rm -rf /tmp/nginx.tar.gz && \
    rm -rf /var/cache/apk/*
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]
WORKDIR /etc/nginx
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]

FROM  alpine:3.16
LABEL Maintainer="Nguyen Chinh <nchinh.vn@gmail.com>"
# Install packages
# RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
#     php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
#     php7-mbstring php7-gd php7-iconv php7-xml php7-simplexml php7-xmlwriter \
#     php7-tokenizer php7-fileinfo php7-pdo_mysql php7-pdo php7-exif php7-zip \ 
#     nginx supervisor curl git openssh bash openssl nodejs npm
RUN apk --no-cache add \ 
    supervisor git nodejs npm openssh nginx bash openssl

RUN  mkdir /root/.ssh/
ADD  id_rsa /root/.ssh/id_rsa
COPY web.supervisord.conf     /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf               /etc/nginx/nginx.conf
RUN chown -R nobody.nobody /run && \
    chown -R nobody.nobody /var/lib/nginx && \
    chown -R nobody.nobody /var/log/nginx && \
    \
    openssl req -x509 -nodes -days 365 \
    -subj "/C=CA/ST=QC/O=Company, Inc./CN=cms.vgs.vn" \
    -addext "subjectAltName=DNS:cms.vgs.vn" -newkey rsa:2048 \
    -keyout /etc/nginx/nginx-selfsigned.key -out /etc/nginx/nginx-selfsigned.crt; 

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
WORKDIR  /var/www/html/

ARG build.2022.08.31
RUN ssh-keyscan github.com > /root/.ssh/known_hosts && \
    mkdir -p /var/www/html/ && cd /var/www/html/ &&  rm -rf * && \
    git clone -b main --depth=1 -v --progress git@github.com:vgs-holding/wap-web-booking-BE.git . && \
    apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev openssl-dev && \
    npm install && \
    echo npm run build && \
    apk del .build-deps && ls /var/www/html/  -lahrt
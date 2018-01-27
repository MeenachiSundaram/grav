FROM ubuntu:16.04

MAINTAINER MeenachiSundaram

ADD grav.conf /etc/php/7.0/fpm/pool.d/grav.conf

RUN apt-get update \
    && apt install -y vim zip unzip nginx git php7.0-fpm php7.0-cli php7.0-gd php7.0-curl php7.0-mbstring php7.0-xml php7.0-zip php-apcu \
    && apt-get clean \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.0/fpm/php.ini \
    && rm /etc/php/7.0/fpm/pool.d/www.conf \
    && useradd -M grav

#https://github.com/getgrav/grav/releases/download/1.3.9/grav-admin-v1.3.9.zip
ADD https://github.com/getgrav/grav/releases/download/1.3.9/grav-admin-v1.3.9.zip /home/repo/grav-admin.zip

RUN mkdir -p /home/grav/www \
    && echo "daemon off;" >> /etc/nginx/nginx.conf \
    && rm /etc/nginx/sites-enabled/default \
    && rm /etc/nginx/sites-available/default \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN service php7.0-fpm start \
    && service php7.0-fpm restart

ADD domain /home/repo/domain

ADD entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

EXPOSE 80 443

CMD ./entrypoint.sh

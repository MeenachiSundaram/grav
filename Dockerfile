FROM ubuntu:16.04

MAINTAINER MeenachiSundaram

RUN apt-get update \
    && apt-get -y upgrade \
    && apt install -y vim zip unzip nginx git php7.0-fpm php7.0-cli php7.0-gd php7.0-curl php7.0-mbstring php7.0-xml php7.0-zip php-apcu \
    && apt-get clean \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.0/fpm/php.ini \
    && rm /etc/php/7.0/fpm/pool.d/www.conf
RUN useradd -M grav \
    && mkdir -p /home/grav/domain1 \
    && echo "<h1>Working...</h1>" > /home/grav/domain1/index.html \
    && echo "<?php phpinfo();" > /home/grav/domain1/info.php \
    && chown -R grav:grav /home/grav/domain1 \
    && echo "daemon off;" >> /etc/nginx/nginx.conf \
    && service php7.0-fpm restart

ADD https://gist.githubusercontent.com/MeenachiSundaram/3d6b0b34ad653968c8565f1786108b31/raw/c324a3e274a3419784eb4df6083dc2d09e047b37/grav.conf /etc/php/7.0/fpm/pool.d/grav.conf
ADD https://gist.githubusercontent.com/MeenachiSundaram/f053a8dda318c40909c8250c9b611e42/raw/b096f507fee23eac0ec35141d862a3eba6b4c8af/domain1 /etc/nginx/sites-available/domain1
ADD https://getgrav.org/download/core/grav-admin/latest /tmp/grav-admin.zip

RUN unzip -q /tmp/grav-admin.zip -d /home/grav/ \
    && rm -rf /home/grav/domain1 \
    && mv /home/grav/*grav* /home/grav/domain1 \
    && chown -R grav:grav /home/grav/domain1 \
    && rm /etc/nginx/sites-enabled/default \
    && ln -sF /etc/nginx/sites-available/domain1 /etc/nginx/sites-enabled/domain1 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && service php7.0-fpm restart

RUN service php7.0-fpm start \
    && service php7.0-fpm status

EXPOSE 80 443

CMD php-fpm7.0 && nginx

#!/bin/bash
set -e
echo "[ INFO ] *******************************STARTING*******************************"
if [[ -z ${DOMAIN} ]]; then
  echo "[ INFO ]  No Domain supplied. Not updating server config"
    else
      echo "[ INFO ]  Domain supplied. Updating server config"
      for name in ${DOMAIN}
      do
        echo $name
        if [[ -d /home/grav/www/${name} ]]; then
          echo "[ INFO ]  Directory for ${name} domain exist"
        else
          echo "[ INFO ]  Creating Directory for ${name} domain"
          unzip -q /home/repo/grav-admin.zip -d /home/grav/www/ && mv /home/grav/www/grav-admin /home/grav/www/$name
        fi
        if [[ -f /etc/nginx/sites-available/$name ]]; then
          echo "[ INFO ]  Nginx configuration already exist for ${name}"
        else
          echo "[ INFO ]  Creating nginx configuration for ${name}"
          cp /home/repo/domain /etc/nginx/sites-available/$name
          sed -i 's/domain/'$name'/g' /etc/nginx/sites-available/$name
          ln -sF /etc/nginx/sites-available/$name /etc/nginx/sites-enabled/$name
        fi
        if [[ -e /home/grav/certs/$name/fullchain.pem && -e /home/grav/certs/$name/privkey.pem ]]; then
          echo "[ INFO ] Configuring SSL for ${name}"
          sed -i 's/#listen 80;/listen 80; \
          server_name '$name' www.'$name'; \
          return 301 https:\/\/$host$request_uri; \
      } \
      server { \
          listen 443 ssl; \
          ssl_certificate \/home\/grav\/certs\/'$name'\/fullchain.pem; \
          ssl_certificate_key \/home\/grav\/certs\/'$name'\/privkey.pem;/g' /etc/nginx/sites-available/$name
          else
            echo "[ INFO ] Not Configuring SSL ${name}"
        fi
        echo "[ INFO ] Creating Command line for ${name}"
        echo -e '#!/bin/bash\ncd /home/grav/www/'${name}' && bin/gpm $*' > /usr/bin/${name} && chmod +x /usr/bin/${name}
      done
fi
echo "[ INFO ] Configuration for all domain were completed"
echo "[ INFO ] Changing owner"
chown -R grav:grav /home/grav/
echo "[ INFO ] Starting php"
service php7.0-fpm start
echo ""
echo "*******************************Use command line to control grav for each of your domains*******************************"
if [[ -z ${DOMAIN} ]]; then
  echo "[ INFO ]  No Domain supplied."
else
  for name in ${DOMAIN}
  do
    echo ""
    echo "for domain $name"
    echo "Run the following command"
    echo "[ CMD ]   docker exec -it <CONTAINER_NAME> $name"
    echo ""
  done
fi
echo "[ INFO ] strating nginx"
echo "[ INFO ] *******************************CONTAINER STARTED SUCESSFULLY*******************************"
service nginx start

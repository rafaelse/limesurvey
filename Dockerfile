FROM nginx:1.17.8
LABEL maintainer="rafaelfernando@ufscar.br"

RUN apt-get -yqq update
RUN apt-get -yqq install php7.3 php7.3-fpm php7.3-gd php7.3-imap php7.3-ldap php7.3-mbstring php7.3-pgsql php7.3-mysql php7.3-zip php7.3-xml zlibc zlib1g-dev zlib1g procps postgresql-client postgresql-client-common netcat

RUN mkdir /run/php/
RUN mkdir /var/www/

ADD ./limesurvey /var/www/limesurvey/
RUN chown -R www-data:www-data /var/www/limesurvey
VOLUME /var/www/limesurvey/upload/

ADD nginx.conf /etc/nginx/nginx.conf
ADD limesurvey.com.conf /etc/nginx/conf.d/www.conf

WORKDIR /var/www/limesurvey/

ADD config.php application/config/config.php

ADD .pgpass .
RUN chmod 600 .pgpass
ENV PGPASSFILE=.pgpass

ADD serve.sh .
RUN chmod +x serve.sh

ENTRYPOINT ["sh", "serve.sh"]
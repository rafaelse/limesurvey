FROM nginx:1.17.8
LABEL maintainer="rafaelfernando@ufscar.br"

RUN apt-get -yqq update
RUN apt-get -yqq install php7.3 php7.3-fpm php7.3-gd php7.3-imap php7.3-ldap php7.3-mbstring php7.3-pgsql php7.3-mysql php7.3-zip php7.3-xml zlibc zlib1g-dev zlib1g procps postgresql-client postgresql-client-common netcat

RUN mkdir /run/php/
RUN mkdir /var/www/

ADD ./src /var/www/limesurvey/
RUN chown -R www-data:www-data /var/www/limesurvey

ADD ./conf/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./conf/nginx/limesurvey.com.conf /etc/nginx/conf.d/www.conf
ADD ./conf/fpm/www.conf /etc/php/7.3/fpm/pool.d/www.conf
ADD ./conf/fpm/php.ini /etc/php/7.3/fpm/php.ini

WORKDIR /var/www/limesurvey/

ADD set_env_variables.sh .
ADD serve.sh .
RUN chmod u+x serve.sh
RUN chmod u+x set_env_variables.sh

ENTRYPOINT ["sh", "serve.sh"]
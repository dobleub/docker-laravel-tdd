FROM debian:stretch-slim

# Set Debian frontend
ENV DEBIAN_FRONTEND noninteractive
# Set Locale
ENV LOCALE es_MX.UTF-8
# Set TimeZone
ENV TZ America/Mexico_City

# Install Basic Packages
RUN \
	echo "deb http://ftp.de.debian.org/debian/ stretch main non-free contrib" > /etc/apt/sources.list && \
	echo "deb-src http://ftp.de.debian.org/debian/ stretch main non-free contrib" >> /etc/apt/sources.list && \
	echo "deb http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
	echo "deb-src http://security.debian.org/ stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
	apt-get update -qq && apt-get -y -qq upgrade

# Install some basic tools needed for deployment
RUN apt-get -yqq install apt-utils build-essential debconf-utils debconf locales curl wget unzip
RUN apt-get install -yqq patch rsync vim openssh-client git bash-completion libjpeg-turbo-progs libjpeg-progs \
	pngcrush optipng gnupg2 apt-transport-https lsb-release ca-certificates

# Install locale
RUN sed -i -e "s/# ${LOCALE}/${LOCALE}/" /etc/locale.gen && \
	echo "LANG=${LOCALE}">/etc/default/locale && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=${LOCALE}

# Install Apache 2 and PHP 7.1.*
RUN apt-get install -yqq apache2
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list && \
    apt-get update -qq && apt-get -y -qq upgrade && \
    apt-get install --no-install-recommends --no-install-suggests -yqq \
    	libapache2-mod-php7.1 \
        php7.1-apc \
        php7.1-apcu \
        php7.1-bz2 \
        php7.1-bcmath \
        php7.1-calendar \
        php7.1-cgi \
        php7.1-cli \
        php7.1-ctype \
        php7.1-curl \
        php7.1-geoip \
        php7.1-gettext \
        php7.1-gd \
        php7.1-intl \
        php7.1-imagick \
        php7.1-imap \
        php7.1-ldap \
        php7.1-mbstring \
        php7.1-mcrypt \
        php7.1-memcached \
        php7.1-mongo \
        php7.1-mysql \
        php7.1-pdo \
        php7.1-pgsql \
        php7.1-redis \
        php7.1-soap \
        php7.1-sqlite3 \
        php7.1-ssh2 \
        php7.1-zip \
        php7.1-xmlrpc \
        php7.1-xsl

# Enable memcache and php-fmp 
RUN apt-get install -yqq pkg-config mailutils libpng-dev zlib1g-dev libmemcached-dev

# Setup Composer | prestissimo to speed up composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
 	composer global require "hirak/prestissimo:^0.3"

# Setup NodeJs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -yqq nodejs
RUN npm install -g bower

# Installing browser
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub |  apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update && apt-get install -y google-chrome-stable && \
    apt-get install -y xvfb

# PHP Timezone
RUN echo "${TZ}" | tee /etc/timezone && \
	dpkg-reconfigure --frontend noninteractive tzdata && \
	echo "date.timezone = \"${TZ}\";" > /etc/php/7.1/cli/conf.d/timezone.ini

# Cleanup apt
RUN apt-get -q autoclean

# Apache enviroment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Update the default Apache site with custom config
ADD .config/app/apache-config.conf /etc/apache2/sites-enabled/000-default.conf
RUN a2enmod rewrite proxy_fcgi setenvif php7.1

# Working dir
WORKDIR /var/www
COPY app /var/www
RUN ln -s /var/www/vendor/bin/phpunit /usr/bin/phpunit
# Update dependencies
# RUN composer install && npm install && bower install --allow-root

RUN usermod -u 1000 www-data && \
	chown -R www-data:www-data /var/www && \
	chmod -R 775 /var/www/storage

# RUN /usr/sbin/apache2ctl restart
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
# Expose
EXPOSE 80 9515

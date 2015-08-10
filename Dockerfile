FROM ubuntu:14.04
MAINTAINER Anjesh Tuladhar <anjesh@yipl.com.np>

RUN apt-get update
RUN apt-get install -y \
                    curl \
                    git \
                    wget
RUN echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" > /etc/apt/sources.list.d/ondrej-php5-5_6-trusty.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN apt-get install -y \
                    apache2 \
                    php5 \
                    php5-cli \
                    php5-curl \
                    php5-mcrypt \
                    php5-pgsql \
                    php5-readline 
RUN apt-get install -y \
                    beanstalkd \
                    pdftk \
                    poppler-utils \
                    supervisor

RUN a2enmod rewrite
RUN a2enmod php5

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80

WORKDIR /var/www/html/
RUN git clone https://github.com/NRGI/resourcecontracts.org.git rc

RUN mkdir /shared_path
RUN mkdir -p /shared_path/rc/{data,storage}
RUN mkdir -p /shared_path/rc/storage/{logs,app,framework}
RUN mkdir -p /shared_path/rc/storage/framework/{cache,sessions,views}
RUN mkdir -p /shared_path/pdfprocessor/logs
RUN chmod -R 777 /shared_path

RUN rm -rf /var/www/html/rc/storage
RUN ln -s /shared_path/rc/storage/ /var/www/html/rc/storage
RUN ln -s /shared_path/rc/data/ /var/www/html/rc/public/data

WORKDIR /var/www/html/rc
RUN curl -s http://getcomposer.org/installer | php
RUN php composer.phar install
RUN php composer.phar dump-autoload --optimize
RUN php artisan clear-compiled

CMD /etc/init.d/beanstalkd start
ADD conf/supervisord.conf /etc/supervisord.conf
CMD /etc/init.d/supervisord start

WORKDIR /var/www/html
RUN git clone https://github.com/anjesh/pdf-processor.git

ADD conf/.env /var/www/html/rc/.env


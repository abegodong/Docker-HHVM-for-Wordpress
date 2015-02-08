FROM phusion/baseimage:0.9.16
MAINTAINER Abegodong <a@rc.lc>

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install curl unzip git

# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Install PHP5
RUN apt-get -y install php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# Install HHVM
RUN wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | apt-key add -
RUN echo deb http://dl.hhvm.com/ubuntu trusty main | tee /etc/apt/sources.list.d/hhvm.list
RUN apt-get update && apt-get install -y hhvm

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/sites-available/default
RUN mkdir /log/nginx

RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run

RUN mkdir /etc/service/hhvm
ADD hhvm.sh /etc/service/hhvm/run

RUN sudo /usr/share/hhvm/install_fastcgi.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install WP
ADD http://wordpress.org/latest.tar.gz /data/src/latest.tar.gz
RUN cd /data/src && tar xvf latest.tar.gz && rm -f latest.tar.gz
RUN mv /data/src/wordpress /data/src/html && rm -rf /data/src/wordpress
RUN chown -R www-data:www-data /data/src/html

VOLUME ["/data/src/wp-content", "/log"]

# private expose
EXPOSE 80

CMD ["/sbin/my_init"]
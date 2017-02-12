FROM jkirkby91/ubuntusrvbase:latest

MAINTAINER James Kirkby <jkirkby91@gmail.com>

RUN apt-get update && \
apt-get upgrade -y && \
apt-get install nginx -y --fix-missing && \
apt-get remove --purge -y software-properties-common build-essential && \
apt-get autoremove -y && \
apt-get clean && \
apt-get autoclean && \
echo -n > /var/lib/apt/extended_states && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /usr/share/man/?? && \
rm -rf /usr/share/man/??_*

RUN mkdir -p /srv/ssl && \
mkdir -p /srv/log && \
mkdir -p /srv/log/nginx && \
mkdir -p /srv/confs && \
mkdir -p /srv/www

COPY confs/nginx/naxsi_core.rules /etc/nginx/naxsi_core.rules

RUN cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

RUN touch /etc/fail2ban/filter.d/nginx-req-limit.conf

COPY confs/fail2ban/nginx-req-limit.conf /etc/fail2ban/filter.d/nginx-req-limit.conf

COPY confs/apparmor/nginx.conf /etc/apparmor/nginx.conf

COPY confs/fail2ban/jail1.conf /tmp/jail.conf

RUN cat /tmp/jail.conf >> /etc/fail2ban/jail.local

RUN rm /tmp/jail.conf

COPY confs/fail2ban/nginx-naxsi.conf /etc/fail2ban/filter.d/nginx-naxsi.conf

COPY confs/jail2.conf /tmp/jail.conf

RUN cat /tmp/jail.conf >> /etc/fail2ban/jail.conf

COPY confs/supervisord.conf /etc/supervisord.conf

COPY start.sh /start.sh

RUN chmod 777 /start.sh

RUN usermod -u 1000 www-data

RUN touch /srv/log/nginx.access.log

RUN touch /srv/log/nginx.error.log

RUN chown -Rf www-data:www-data /srv

RUN chmod 755 /srv

RUN find /srv -type d -exec chmod 755 {} \;

RUN find /srv -type f -exec chmod 644 {} \;

CMD ["/bin/bash", "/start.sh"]
FROM alpine:v3.18
LABEL Maintainer="Mario Lombardo <ml@akamo.de>" \
      Description="Lightweight container for backup destination"

# Install packages and remove default server definition
RUN apk --no-cache add supervisor borgbackup openssh-server

RUN rm -rf /etc/ssh

# Configure supervisord
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/sshd_config /etc/sshd.conf
COPY scripts/init.sh /init.sh

# Setup document root
RUN mkdir -p /backup/destination
RUN adduser -g "" -D -H -h /backup/destination/backup -s /bin/sh backup
RUN echo "HISTFILE=/dev/null" >> /etc/profile

# A little cleaning
RUN rm -f /sbin/apk; rm -rf /etc/apk; rm -rf /lib/apk; rm -rf /usr/share/apk; rm -rf /var/lib/apk
RUN find /sbin/ -type l -exec rm {} +
RUN find /usr/sbin/ -type l -exec rm {} +
RUN rm -rf /etc/init.d /etc/inittab /etc/periodic /etc/crontabs /etc/conf.d udhcpd.conf /etc/opt

# Let supervisord start cron
CMD ["/init.sh"]

EXPOSE 2222

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD /usr/bin/supervisorctl status || exit 1

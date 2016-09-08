FROM python:3.5.2
MAINTAINER Nuts Project, LLC

RUN apt-get update && apt-get install -y sudo && apt-get clean \
    && groupadd -g 1000 mkdocs && useradd -u 1000 -g mkdocs mkdocs \
    && echo "mkdocs ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN pip install mkdocs==0.15.3 \
    && mkdocs new /mkdocs \
    && tar czf /mkdocs.tar.gz -C /mkdocs ./

ENV APACHE_RUN_USER mkdocs
ENV APACHE_RUN_GROUP mkdocs
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN apt-get update && apt-get install -y apache2 && apt-get clean \
    && mkdir -p /var/run/apache2 \
    && mkdir -p /var/lock/apache2

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR /mkdocs

EXPOSE 80

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

FROM python:3.5.2
MAINTAINER Nuts Project, LLC

RUN apt-get update && apt-get install -y sudo && apt-get clean \
    && groupadd mkdocs && useradd -g mkdocs mkdocs \
    && echo "mkdocs ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN pip install mkdocs==0.15.3 \
    && mkdocs new /mkdocs \
    && tar czf /mkdocs.tar.gz -C /mkdocs ./ \
    && mkdir -p /mkdocs

COPY docker-entrypoint.sh /entrypoint.sh

USER mkdocs
WORKDIR /mkdocs

ENTRYPOINT [ "/entrypoint.sh" ]

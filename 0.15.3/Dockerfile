FROM python:3.5.2
MAINTAINER Nuts Project, LLC

RUN apt-get update && apt-get install -y sudo && apt-get clean \
    && groupadd mkdocs && useradd -g mkdocs mkdocs \
    && echo "mkdocs ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN pip install mkdocs==0.15.3 \
    && mkdocs new /mkdocs \
    && echo "docs_dir: /mkdocs/docs"

COPY entrypoint.sh /entrypoint.sh
RUN chown mkdocs:mkdocs /entrypoint.sh

USER mkdocs
WORKDIR /mkdocs

ENTRYPOINT [ "/entrypoint.sh" ]

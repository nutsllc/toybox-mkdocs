#!/bin/bash
set -e

user="mkdocs"
group="mkdocs"

if [ -n "${TOYBOX_GID}" ] && ! cat /etc/passwd | awk 'BEGIN{ FS= ":" }{ print $4 }' | grep ${TOYBOX_GID} > /dev/null 2>&1; then
    sudo groupmod -g ${TOYBOX_GID} ${group}
    echo "GID of ${group} has been changed."
fi

if [ -n "${TOYBOX_UID}" ] && ! cat /etc/passwd | awk 'BEGIN{ FS= ":" }{ print $3 }' | grep ${TOYBOX_UID} > /dev/null 2>&1; then
    sudo usermod -u ${TOYBOX_UID} ${user}
    echo "UID of ${user} has been changed."
fi

MKDOCS_ROOT="/mkdocs"
sudo tar xzf /mkdocs.tar.gz -C ${MKDOCS_ROOT}
sudo chown -R ${user}:${group} ${MKDOCS_ROOT}

out="${MKDOCS_ROOT}/mkdocs.yml"
echo "docs_dir: /mkdocs/docs" > ${out}
{
    echo "site_name: ${SITE_NAME:=My Docs}"
    echo "repo_url: ${REPO_URL}"
    echo "repo_name: ${REPO_NAME}"
    echo "site_description: ${SITE_DESCRIPTION}"
    echo "site_author: ${SITE_AUTHOR}"
    echo "copyright: ${COPYRIGHT}"
    echo "site_favicon: ${SITE_FAVICON}"
    echo "google_analytics: ${GOOGLE_NALYTICS}"
    echo "remote_branch: ${REMOTE_BRANCH:=gh-pages}"
    echo "remote_name: ${REMOTE_NAME:=gh-pages}"
    echo "theme: ${THEME:=mkdocs}"
    echo "site_dir: ${SITE_DIR:=/var/www/html}"
} >> ${out}
mkdocs build --config-file ${MKDOCS_ROOT}/mkdocs.yml

exec $@

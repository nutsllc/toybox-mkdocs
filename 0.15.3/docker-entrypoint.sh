#!/bin/bash

user="www-data"
group="www-data"

if [ -n "${TOYBOX_GID}" ] && ! cat /etc/passwd | awk 'BEGIN{ FS= ":" }{ print $4 }' | grep ${TOYBOX_GID} > /dev/null 2>&1; then
    sudo groupmod -g ${TOYBOX_GID} ${group}
    echo "GID of ${group} has been changed."
fi

if [ -n "${TOYBOX_UID}" ] && ! cat /etc/passwd | awk 'BEGIN{ FS= ":" }{ print $3 }' | grep ${TOYBOX_UID} > /dev/null 2>&1; then
    sudo usermod -u ${TOYBOX_UID} ${user}
    echo "UID of ${user} has been changed."
fi

# --------------------------------------
# MKDocs
# --------------------------------------
tar xzf /mkdocs.tar.gz -C ${MKDOCS_ROOT} && {
    rm /mkdocs.tar.gz
    mkdir -p ${MKDOCS_ROOT}/conf
    if [ ! -f ${MKDOCS_ROOT}/conf/mkdocs.yml ]; then
        {
            echo "docs_dir: /mkdocs/docs"
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
        } > ${MKDOCS_ROOT}/conf/mkdocs.yml
    fi
    ln -sf ${MKDOCS_ROOT}/conf/mkdocs.yml ${MKDOCS_ROOT}/mkdocs.yml

    if [ ! -f ${MKDOCS_ROOT}/deploy.sh ]; then
        {
            echo "#!/bin/sh"
            echo "set -e"
            echo ""
            echo "rm -rf ${MKDOCS_ROOT}/docs"
            echo "cp -r ${MKDOCS_ROOT}/docs-hook ${MKDOCS_ROOT}/docs"
            echo "mkdocs build --clean --config-file ${MKDOCS_ROOT}/mkdocs.yml"
            echo ""
            echo "exit 0"
        } > ${MKDOCS_ROOT}/deploy.sh
    fi

    chown -R ${user}:${group} ${MKDOCS_ROOT}
}
#mkdocs build --config-file ${MKDOCS_ROOT}/mkdocs.yml

# --------------------------------------
# webhook
# --------------------------------------
tar xzf /Git-Auto-Deploy.tar.gz -C ${WEBHOOK_ROOT} && {
    rm /Git-Auto-Deploy.tar.gz
    mkdir -p ${WEBHOOK_ROOT}/conf
    if [ ! -f ${WEBHOOK_ROOT}/conf/config.json ]; then
        mv /config.json ${WEBHOOK_ROOT}/conf/config.json
    else
        rm /config.json
    fi
    ln -sf ${WEBHOOK_ROOT}/conf/config.json ${WEBHOOK_ROOT}/config.json
    chown -R ${user}:${group} ${WEBHOOK_ROOT}
}

exec $@

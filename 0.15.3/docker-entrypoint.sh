#!/bin/bash
set -e

user="www-data"
group="www-data"

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
    chown -R ${user}:${group} ${MKDOCS_ROOT}
    mkdocs build --clean --config-file ${MKDOCS_ROOT}/mkdocs.yml
}

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

    if [ -n ${CLONE_URL} -a "${CLONE_URL}" != "" ]; then
        sed -i -e s%"https\?://.*"%"${CLONE_URL}"\",% ${WEBHOOK_ROOT}/conf/config.json
    fi

    if [ ! -f ${WEBHOOK_ROOT}/deploy.sh ]; then
        {
            echo "#!/bin/sh"
            echo "set -e"
            echo ""
            echo "rm -rf ${MKDOCS_ROOT}/docs"
            echo "cp -r ${WEBHOOK_ROOT}/docs-hook ${MKDOCS_ROOT}/docs"
            echo "mkdocs build --clean --config-file ${MKDOCS_ROOT}/mkdocs.yml"
            echo ""
            echo "exit 0"
        } > ${WEBHOOK_ROOT}/deploy.sh
    fi

    chown -R ${user}:${group} ${WEBHOOK_ROOT}
}

exec $@

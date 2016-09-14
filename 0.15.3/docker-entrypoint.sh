#!/bin/bash
set -e

user="www-data"
group="www-data"

if [ -n "${TOYBOX_GID}" ] && ! cat /etc/group | awk 'BEGIN{ FS= ":" }{ print $3 }' | grep ${TOYBOX_GID} > /dev/null 2>&1; then
    groupmod -g ${TOYBOX_GID} ${group}
    echo "GID of ${group} has been changed."
fi

if [ -n "${TOYBOX_UID}" ] && ! cat /etc/passwd | awk 'BEGIN{ FS= ":" }{ print $3 }' | grep ${TOYBOX_UID} > /dev/null 2>&1; then
    usermod -u ${TOYBOX_UID} ${user}
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
    chown -R ${user}:${group} ${MKDOCS_ROOT}
    mkdocs build --clean --config-file ${MKDOCS_ROOT}/mkdocs.yml
}

# --------------------------------------
# webhook
# --------------------------------------
#if [ -z "${GIT_CLONE_URL}" -a "${GIT_CLONE_URL}" = "" ]; then
if [ -z "${GIT_CLONE_URL}" ]; then
    rm /Git-Auto-Deploy.tar.gz
else
    tar xzf /Git-Auto-Deploy.tar.gz -C ${WEBHOOK_ROOT} && {
        rm /Git-Auto-Deploy.tar.gz
        mkdir -p ${WEBHOOK_ROOT}/conf
        if [ ! -f ${WEBHOOK_ROOT}/conf/config.json ]; then
            mv /config.json ${WEBHOOK_ROOT}/conf/config.json
        else
            rm /config.json
        fi
        ln -sf ${WEBHOOK_ROOT}/conf/config.json ${WEBHOOK_ROOT}/config.json
        sed -i -e s%"https\?://.*"%"${GIT_CLONE_URL}"\",% ${WEBHOOK_ROOT}/conf/config.json
    
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
    
        {
            echo "[program:webhook]"
            echo "command=$(which python) ${WEBHOOK_ROOT}/gitautodeploy --config ${WEBHOOK_ROOT}/conf/config.json"
            echo "autorestart=true"
            #echo "stdout_logfile=${WEBHOOK_ROOT}/log/webhook.log"
            #echo "stderr_logfile=${WEBHOOK_ROOT}/log/webhook_err.log"
            echo "stdout_logfile=/dev/fd/1"
            echo "stderr_logfile=/dev/fd/1"
            echo "stdout_logfile_maxbytes=0"
            echo "stderr_logfile_maxbytes=0"
        } >> /etc/supervisor/conf.d/supervisord.conf
    
        chown -R ${user}:${group} ${WEBHOOK_ROOT}
    }
fi

exec $@

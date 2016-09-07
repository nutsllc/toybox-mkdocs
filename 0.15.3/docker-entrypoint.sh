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

tar xzf /mkdocs.tar.gz -C /mkdocs
chown -R ${user}:${group} /mkdocs

mkdocs serve -a 0.0.0.0:8000

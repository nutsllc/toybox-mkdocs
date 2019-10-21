#!/bin/sh 

name="mkdocs"
port="8080"

function _run() {
    docker run --name ${name} -p ${port}:80 -v $(pwd)/mkdown:/mkdocs/docs -v $(pwd)/html:/var/www/html -itd mkdocs
}

function _build() {
    docker exec -itd ${container_id} mkdocs build --config-file /mkdocs/mkdocs.yml
}

if [ $1 != "run" -a $1 != "build" ]; then
    echo "error: command error.; exit 1
fi

cmd=$1; shift
_${cmd} $@

exit 0

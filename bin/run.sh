#! /bin/bash

PLAYBOOK_DIR=$(echo ${GIT_URL} | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}')
GIT_URL=$(echo ${GIT_URL} | cut -f3- -d '/')

git clone https://${GIT_USER}:${GIT_TOKEN}@${GIT_URL}
cd ${PLAYBOOK_DIR}
ansible-playbook site.yml
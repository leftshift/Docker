#!/bin/bash
set -e -x

build_client() {
    echo "Cloning and building client..."
    cd /opt/anfora/src/
    git clone https://github.com/anforaProject/client.git client
    cd client/
    yarn install
    yarn build
}

sync_db() {
    echo "Syncing db..."
    cd /opt/anfora/src
    pipenv run python commands.py -d
}

generate_config() {
    echo "Generating config from yaml..."
    cd /opt/anfora/src/
    pipenv run python commands.py -s --config config/docker-compose.yaml
}

link_dist() {
    echo "Movin client dist to /var/anfora and linking it back"
    rm -rf /var/anfora/dist
    mv /opt/anfora/src/client/dist /var/anfora/
    ln -sf /var/anfora/dist /opt/anfora/src/client/dist
}

create_dirs() {
    mkdir -p /var/anfora/media/max_resolution
    mkdir -p /var/anfora/media/small
}

generate_config

FIRST_RUN_SENTINEL=/opt/anfora/initialized
if [ -e "$FIRST_RUN_SENTINEL" ]
then
    echo "Not the first run of anfora, skipping setup..."
else
    echo "Initial run, doing some setup..."
    build_client
    link_dist
    create_dirs
    sync_db
    touch "$FIRST_RUN_SENTINEL"
fi

echo "Staring anfora components"
cd /opt/anfora/src
pipenv run huey_consumer.py tasks.main.huey -m 1 -w 4 &
pipenv run python main.py

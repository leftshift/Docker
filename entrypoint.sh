#!/bin/bash
set -e

build_client() {
    echo "Cloning and building client..."
    cd /opt/anfora/src/client
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
    cd /opt/anfora/src/config
    pipenv run python commands.py -s --config docker-compose.yaml
}

FIRST_RUN_SENTINEL=/var/anfora/initialized
if [ -e "$FIRST_RUN_SENTINEL" ]
then
    echo "Not the first run of anfora, skipping setup..."
else
    echo "Initial run, doing some setup..."
    build_client
    sync_db
    touch FIRST_RUN_SENTINEL
fi

generate_config

echo "Staring anfora components"
cd /opt/anfora/src
pipenv run huey_consumer.py tasks.main.huey -m 1 -w 4
pipenv run python main.py

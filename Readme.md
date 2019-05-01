# Work in progress dockerfile and docker-compose for anfora

Includes anfora core components, redis, postgres, nginx

## Usage
clone this repo with submodules (`git clone --recurse-submodules ...`)

You also need docker and docker-compose.

To (re)build the core anfora container, run `docker-compose build`. This takes a while the first time but should be fairly quick after that.

To start, run `docker-compose up`.

## Issues
Right now, the code for the anfora frontend is cloned and built on the first run. This is suboptimal and will be changed.
Also, SMTP isn't set up correctly by default.

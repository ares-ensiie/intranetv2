# Intranet

## Prerequisites
* [Docker and Docker compose](https://docs.docker.com/compose/install)

## Instructions
* `cd Intranet`
* `cp ./config/ldap.yml.template ./config/ldap.yml`

## Running in development mode using docker
* `docker-compose build`      
* `docker-compose run app rails db:create db:migrate db:seed`        
* `docker-compose up`

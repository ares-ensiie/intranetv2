# Intranet

## Prerequisites
* [Docker and Docker compose](https://docs.docker.com/compose/install)

## Instructions
* `cd Intranet`
* `cp ./config/ldap.yml.template ./config/ldap.yml`

## Running in development mode using docker
* `docker-compose build`     
If you get an error 'Couldn't connect to Docker daemon', run `usermod -aG docker ${USER}` then login/logout (or reboot)   
* In order to create the database, make sure you have a user called 'intranet', if not, create it by using the following commands :
    * `sudo -u postgres -i`
    * `pgsql`
    * `create user intranet createdb password 'intranet';`
    * `\q` then `exit`
* `docker-compose run app rake db:create db:migrate db:seed`        
* `docker-compose up`

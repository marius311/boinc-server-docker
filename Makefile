default:

DC=docker-compose


up: up-mysql post-makeproject up-apache

down: 
	$(DC) down

build: 
	$(DC) build

pull: 
	$(DC) pull


#--- project ---

makeproject: 
	$(DC) build makeproject

post-makeproject:
	$(DC) run --rm makeproject


#--- apache ---

build-apache:
	$(DC) build apache

up-apache:
	$(DC) up -d apache

rm-apache:
	$(DC) stop apache && $(DC) rm -f apache

exec-apache:
	$(DC) exec apache bash


# --- mysql ---

build-mysql: 
	$(DC) build mysql

up-mysql:
	$(DC) up -d mysql

rm-mysql:
	$(DC) stop mysql && $(DC) rm -f mysql


# --- for local building/testing ---

TAG=$(shell git describe --tags --abbrev=0)
tag:
	docker tag boinc/server_apache:latest-b2d boinc/server_apache:$(TAG)-b2d
	docker tag boinc/server_mysql:latest boinc/server_mysql:$(TAG)
	docker tag boinc/server_makeproject:latest-b2d boinc/server_makeproject:$(TAG)-b2d

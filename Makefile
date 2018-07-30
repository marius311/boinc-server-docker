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
	$(DC) exec -u boincadm apache bash


# --- mysql ---

build-mysql: 
	$(DC) build mysql

up-mysql:
	$(DC) up -d mysql

rm-mysql:
	$(DC) stop mysql && $(DC) rm -f mysql


# --- for local building/testing ---

VER=$(shell git describe --tags --abbrev=0)
tag:
	docker tag boinc/server_apache:latest$(TAG) boinc/server_apache:$(VER)$(TAG)
	docker tag boinc/server_mysql:latest boinc/server_mysql:$(VER)
	docker tag boinc/server_makeproject:latest$(TAG) boinc/server_makeproject:$(VER)$(TAG)

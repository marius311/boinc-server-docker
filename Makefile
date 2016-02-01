default:

DC=docker-compose

up: up-mysql post-makeproject up-apache

build: 
	$(DC) build

pull: 
	$(DC) pull


#--- project ---

makeproject: 
	$(DC) build makeproject

post-makeproject:
	$(DC) run --rm makeproject /root/postbuild.py


#--- apache ---

build-apache:
	$(DC) build apache

up-apache:
	$(DC) up -d apache

rm-apache:
	$(DC) stop apache && $(DC) rm -f apache

exec-apache:
	docker exec -it boincserver_apache bash


# --- mysql ---

build-mysql: 
	$(DC) build mysql

up-mysql:
	$(DC) up -d mysql

rm-mysql:
	$(DC) stop mysql && $(DC) rm -f mysql

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

build-and-tag-all:
	for TAG in "" "-b2d"; do \
	    for DEFAULTARGS in "" "-defaultargs"; do \
	        for VERSION in "latest" $(shell git describe --tags --abbrev=1); do \
	            export TAG VERSION DEFAULTARGS ; \
	            docker-compose build 2>&1 | grep --color=never "Successfully tagged"; \
	        done ; \
	    done ; \
	done
	
push-all:
	for TAG in "" "-b2d"; do \
	    for DEFAULTARGS in "" "-defaultargs"; do \
	        for VERSION in "latest" $(shell git describe --tags --abbrev=1); do \
	            export TAG VERSION DEFAULTARGS ; \
	            docker-compose push ; \
	        done ; \
	    done ; \
	done

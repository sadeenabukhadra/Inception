Name = inception

COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker compose -f $(COMPOSE_FILE)

all : up

up:
	$(COMPOSE) up -d --build

build :
	$(COMPOSE) build

down :
	$(COMPOSE) down

start :
	$(COMPOSE) start

stop :
	$(COMPOSE) stop

restart:
	$(COMPOSE) restart

logs :
	$(COPMOSE) logs

ps :
	$(COMPOSE) ps

clean :
	$(COMPOSE) down --remove-orphans

fclean:
	$(COMPOSE) down --volumes --remove-orphans

re:fclean all

.PHONY: all up build down start stop restart logs ps clean fclean re



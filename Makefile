NAME = inception

LOGIN = sabu-kha
DATA_PATH = /home/$(LOGIN)/data

COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker compose -f $(COMPOSE_FILE)

all : up

up:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@docker volume create --driver local \
		--opt type=none \
		--opt device=$(DATA_PATH)/mariadb \
		--opt o=bind \
		mariadb_data || true
	@docker volume create --driver local \
		--opt type=none \
		--opt device=$(DATA_PATH)/wordpress \
		--opt o=bind \
		wordpress_data || true
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
	$(COMPOSE) logs

ps :
	$(COMPOSE) ps

clean :
	$(COMPOSE) down --remove-orphans

fclean: clean
	$(COMPOSE) down --volumes --remove-orphans
	@docker volume rm mariadb_data wordpress_data 2>/dev/null || true
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all up build down start stop restart logs ps clean fclean re

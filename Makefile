COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

all: setup build up

setup:
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/portainer

build:
	@docker-compose -f $(COMPOSE_FILE) build

up:
	@docker-compose -f $(COMPOSE_FILE) up -d

down:
	@docker-compose -f $(COMPOSE_FILE) down 2>/dev/null || true

stop:
	@docker-compose -f $(COMPOSE_FILE) stop

start:
	@docker-compose -f $(COMPOSE_FILE) start

restart: stop start

logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

ps:
	@docker-compose -f $(COMPOSE_FILE) ps

clean: down
	@docker system prune -af

fclean: clean
	@sudo rm -rf $(DATA_PATH)/wordpress/*; \
	sudo rm -rf $(DATA_PATH)/mariadb/*; \
	sudo rm -rf $(DATA_PATH)/portainer/*; \
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true; \
	echo "✓ full cleanup complete"; \

re: fclean all

.PHONY: all setup build up down stop start restart logs ps clean fclean re

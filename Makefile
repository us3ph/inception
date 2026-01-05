#variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/$(USER)/data

all: setup build up

#setup create necessary directories
setup:
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb

#build all docker images
build:
	@docker-compose -f $(COMPOSE_FILE) build

up:
	@docker-compose -f $(COMPOSE_FILE) up -d

down:
	@docker-compose -f $(COMPOSE_FILE) down 2>/dev/null || true

#stop containers without removing
stop:
	@docker-compose -f $(COMPOSE_FILE) stop

#start existing containers
start:
	@docker-compose -f $(COMPOSE_FILE) start

#restart all containers
restart: stop start

#show container logs
logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

#list running containers
ps:
	@docker-compose -f $(COMPOSE_FILE) ps

#remove containers and networks
clean: down
	@docker system prune -af

#full cleanup including data
fclean: clean
	@sudo rm -rf $(DATA_PATH)/wordpress/*; \
	sudo rm -rf $(DATA_PATH)/mariadb/*; \
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true; \
	echo "✓ full cleanup complete"; \

#rebuild everything
re: fclean all

#these aren't actual files
.PHONY: all setup build up down stop start restart logs ps clean fclean re

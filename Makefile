NAME = inception

all: create_env
	@mkdir -p /home/${USER}/data
	@mkdir -p /home/${USER}/data/mariadb
	@mkdir -p /home/${USER}/data/wordpress
	@printf "Building and setting configuration for ${NAME}...\n"
	@docker-compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build

create_env:
	@printf "Creating .env file...\n"
	@echo "DOMAIN_NAME=${USER}.42.fr" > srcs/.env
	@echo "" >> srcs/.env
	@echo "CERT_=./requirements/tools/${USER}.42.fr.crt" >> srcs/.env
	@echo "" >> srcs/.env
	@echo "KEY_=./requirements/tools/${USER}.42.fr.key" >> srcs/.env
	@echo "" >> srcs/.env
	@echo "DB_NAME=wordpress" >> srcs/.env
	@echo "" >> srcs/.env
	@echo "DB_USER=${USER}" >> srcs/.env
	@echo "" >> srcs/.env
	@echo "DB_ROOT=123456" >> srcs/.env
	@echo "" >> srcs/.env
	@echo "DB_PASS=123456" >> srcs/.env
	@echo "" >> srcs/.env
	@echo "WP_USER=guest" >> srcs/.env
	@echo "" >> srcs/.env
	@echo "WP_PASS=123456" >> srcs/.env

down:
	@printf "Stopping ${NAME}...\n"
	@docker-compose -f srcs/docker-compose.yml down

clean: down
	@printf "Stopping and cleaning up all docker configurations of ${NAME}...\n"
	@docker system prune -a

fclean:
	@printf "Cleaning all configuration of ${NAME} and both volumes and host data...\n"
	@if [ -n "$$(docker ps -qa)" ]; then docker stop $$(docker ps -qa); fi
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@docker image prune --all --force
	@docker container prune --force
	@docker builder prune --all --force
	@if [ -n "$$(docker volume ls -q)" ]; then docker volume rm $$(docker volume ls -q); fi
	@if [ -d "/home/${USER}/data" ]; then sudo rm -rf /home/${USER}/data; fi
	@if [ -f "srcs/.env" ]; then rm -f srcs/.env; fi

re:	clean all

.PHONY	: all build down re clean fclean
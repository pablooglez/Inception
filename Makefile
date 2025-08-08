# ===============================
# MAKEFILE FOR INCEPTION PROJECT
# ===============================
# This Makefile automates Docker stack management
# Includes commands to build, run, stop and clean the project

# Project name
NAME = inception

# ===============================
# MAIN TARGET - Build and run
# ===============================
all:
	@mkdir -p /home/${USER}/data                    # Create base directory for persistent data
	@mkdir -p /home/${USER}/data/mariadb            # Create directory for MariaDB data
	@mkdir -p /home/${USER}/data/wordpress          # Create directory for WordPress files
	@printf "Building and setting configuration for ${NAME}...\n"
	@docker-compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build
	# Previous command: builds images and runs containers in background

# ===============================
# STOP SERVICES
# ===============================
down:
	@printf "Stopping ${NAME}...\n"
	@docker-compose -f srcs/docker-compose.yml down  # Stop and remove containers, keep volumes

# ===============================
# BASIC CLEANUP - Stop and clean Docker system
# ===============================
clean: down
	@printf "Stopping and cleaning up all docker configurations of ${NAME}...\n"
	@docker system prune -a                         # Remove unused images, containers and networks

# ===============================
# FULL CLEANUP - Remove everything (containers, volumes, images, data)
# ===============================
fclean:
	@printf "Cleaning all configuration of ${NAME} and both volumes and host data...\n"
	@if [ -n "$$(docker ps -qa)" ]; then docker stop $$(docker ps -qa); fi     # Stop all containers
	@docker system prune --all --force --volumes    # Remove everything: images, containers, volumes, networks
	@docker network prune --force                   # Remove all unused networks
	@docker volume prune --force                    # Remove all unused volumes
	@docker image prune --all --force               # Remove all unused images
	@docker container prune --force                 # Remove all stopped containers
	@docker builder prune --all --force             # Clean Docker build cache
	@if [ -n "$$(docker volume ls -q)" ]; then docker volume rm $$(docker volume ls -q); fi  # Remove remaining volumes
	@if [ -d "/home/${USER}/data" ]; then sudo rm -rf /home/${USER}/data; fi   # Remove host data

# ===============================
# REBUILD - Clean and rebuild
# ===============================
re:	clean all                                       # Execute clean followed by all

# Declare these targets are not files
.PHONY	: all build down re clean fclean
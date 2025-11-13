# 🏗️ Inception - Infraestructura Docker con LEMP Stack

<div align="center">

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-0D597F?style=for-the-badge&logo=alpine-linux&logoColor=white)

**Una implementación completa de infraestructura como código usando Docker y Docker Compose**

[Características](#-características) • [Arquitectura](#-arquitectura) • [Instalación](#-instalación) • [Uso](#-uso) • [Tecnologías](#-tecnologías)

</div>

---

## 📋 Descripción

**Inception** es un proyecto de infraestructura que implementa un stack LEMP completo (Linux, Nginx, MariaDB, PHP) utilizando Docker y Docker Compose. El proyecto automatiza el despliegue de WordPress en un entorno containerizado, con cada servicio ejecutándose en su propio contenedor aislado.

Este proyecto demuestra competencias en:
- 🐳 **Containerización y orquestación** con Docker
- 🔒 **Configuración de seguridad** con SSL/TLS
- 🗄️ **Gestión de bases de datos** con MariaDB
- 🌐 **Configuración de servidores web** con Nginx
- 📦 **Automatización de despliegue** con scripts bash
- 💾 **Gestión de datos persistentes** con volúmenes Docker

## ✨ Características

### 🎯 Principales funcionalidades

- **Arquitectura de microservicios**: Cada componente ejecutándose en contenedores independientes
- **SSL/TLS integrado**: Comunicación segura con certificados autofirmados
- **Datos persistentes**: Volúmenes Docker para almacenamiento permanente
- **Configuración automatizada**: Scripts para instalación y configuración sin intervención manual
- **Healthchecks**: Monitoreo del estado de los servicios
- **Gestión simplificada**: Comandos Makefile para operaciones comunes

### 🔐 Seguridad implementada

- Certificados SSL para conexiones HTTPS
- Aislamiento de red mediante Docker networks
- Usuarios no privilegiados en contenedores
- Variables de entorno para credenciales sensibles
- Configuración segura de MariaDB con eliminación de usuarios por defecto

## 🏛️ Arquitectura

### Diagrama de componentes

```
┌─────────────────────────────────────────────────────┐
│                   Host System                       │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │            Docker Network (bridge)          │    │
│  │                                             │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐   │    │
│  │  │  Nginx   │  │WordPress │  │ MariaDB  │   │    │
│  │  │          │◄─┤          │◄─┤          │   │    │
│  │  │ :443     │  │ :9000    │  │ :3306    │   │    │
│  │  └──────────┘  └──────────┘  └──────────┘   │    │
│  │       ▲             ▲             ▲         │    │
│  └───────┼─────────────┼─────────────┼─────────┘    │
│          │             │             │              │
│  ┌───────▼──────┐ ┌────▼────┐ ┌─────▼─────┐         │
│  │ SSL Certs    │ │WP Files │ │ DB Data   │         │
│  │ /etc/nginx   │ │/var/www │ │/var/lib   │         │
│  └──────────────┘ └─────────┘ └───────────┘         │
│                                                     │
│  Volumes: /home/user/data/                          │
└─────────────────────────────────────────────────────┘
```

### 📦 Estructura del proyecto

```
inception/
├── Makefile                    # Automatización de comandos
├── srcs/
│   ├── .env                    # Variables de entorno
│   ├── docker-compose.yml      # Orquestación de servicios
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile      # Imagen personalizada Nginx
│       │   └── conf/
│       │       └── nginx.conf  # Configuración del servidor
│       ├── wordpress/
│       │   ├── Dockerfile      # Imagen personalizada WordPress
│       │   └── conf/
│       │       ├── wp-config.sh    # Generador de configuración
│       │       └── wp-setup.sh     # Script de instalación
│       └── mariadb/
│           ├── Dockerfile      # Imagen personalizada MariaDB
│           └── conf/
│               └── db.sh       # Script de inicialización BD
└── README.md
```

## 🚀 Instalación

### Prerrequisitos

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Make** (para usar comandos automatizados)
- **Sistema operativo**: Linux (recomendado) o macOS
- **Permisos**: Usuario con acceso a Docker

### Pasos de instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/inception.git
   cd inception
   ```

2. **Configurar variables de entorno**
   ```bash
   # Editar el archivo srcs/.env con tus valores
   vim srcs/.env
   ```
   
   Variables requeridas:
   ```env
   DOMAIN_NAME=usuario.42.fr    # Tu dominio
   DB_NAME=wordpress            # Nombre de la base de datos
   DB_USER=dbuser              # Usuario de la base de datos
   DB_PASS=securepwd           # Contraseña de la base de datos
   DB_ROOT=rootpwd             # Contraseña root de MariaDB
   WP_USER=wpuser              # Usuario de WordPress
   WP_PASS=wppwd               # Contraseña de WordPress
   ```

3. **Construir y ejecutar**
   ```bash
   make
   ```

## 📖 Uso

### Comandos principales

```bash
# Construir e iniciar todos los servicios
make

# Detener los servicios
make down

# Limpiar contenedores e imágenes (mantiene volúmenes)
make clean

# Limpieza completa (incluye volúmenes y datos)
make fclean

# Reconstruir desde cero
make re
```

### Acceso a la aplicación

Una vez desplegado, accede a WordPress mediante:

```
https://tu-dominio.42.fr
```

**Nota**: Al usar certificados autofirmados, el navegador mostrará una advertencia de seguridad que puedes aceptar para continuar.

### Panel de administración

```
URL: https://tu-dominio.42.fr/wp-admin
Usuario: [DB_USER configurado]
Contraseña: [DB_PASS configurado]
```

## 🛠️ Tecnologías

### Stack principal

| Tecnología | Versión | Descripción |
|------------|---------|-------------|
| **Docker** | 20.10+ | Containerización de servicios |
| **Docker Compose** | 3.0 | Orquestación multi-contenedor |
| **Nginx** | Latest | Servidor web y proxy reverso |
| **MariaDB** | 10.x | Sistema de gestión de base de datos |
| **PHP-FPM** | 8.2 | Procesador FastCGI para PHP |
| **WordPress** | 6.5.2 | CMS para gestión de contenido |
| **Alpine Linux** | 3.16-3.18 | Sistema operativo base (ligero) |

### Herramientas adicionales

- **WP-CLI**: Gestión de WordPress por línea de comandos
- **OpenSSL**: Generación de certificados SSL
- **Make**: Automatización de tareas

## 🔧 Configuración avanzada

### Personalización de SSL

Para usar certificados válidos en lugar de autofirmados:

1. Coloca tus certificados en `srcs/requirements/tools/`
2. Actualiza las rutas en el archivo `.env`:
   ```env
   CERT_=./requirements/tools/tu-certificado.crt
   KEY_=./requirements/tools/tu-llave.key
   ```

### Configuración de red

El proyecto utiliza una red bridge de Docker para comunicación interna:

```yaml
networks:
  inception:
    driver: bridge
```

### Volúmenes persistentes

Los datos se almacenan en:
- **WordPress**: `/home/$USER/data/wordpress`
- **MariaDB**: `/home/$USER/data/mariadb`

## 🐛 Solución de problemas

### Problemas comunes

**Error: Puerto 443 en uso**
```bash
# Verificar qué proceso usa el puerto
sudo lsof -i :443
# Detener el servicio conflictivo o cambiar el puerto
```

**Error: Permisos en volúmenes**
```bash
# Ajustar permisos
sudo chown -R $USER:$USER /home/$USER/data
```

**MariaDB no inicia**
```bash
# Verificar logs del contenedor
docker logs mariadb
# Limpiar y reconstruir
make fclean && make
```

## 📚 Aprendizajes clave

Este proyecto me permitió desarrollar competencias en:

- **Docker avanzado**: Multi-stage builds, healthchecks, networks personalizadas
- **Seguridad**: Implementación de SSL/TLS, gestión segura de credenciales
- **Automatización**: Scripts bash para configuración y despliegue
- **Troubleshooting**: Resolución de problemas en entornos containerizados
- **Documentación**: Creación de documentación técnica clara y completa

## 👨‍💻 Autor

**Pablo González**

- GitHub: [@pablogon](https://github.com/pablooglez)

---

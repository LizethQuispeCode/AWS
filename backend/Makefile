.PHONY: help build run test clean docker-build docker-run docker-stop docker-logs deploy

help:
	@echo "Backend Spring Boot - Comandos disponibles:"
	@echo ""
	@echo "  make build           - Compilar con Maven"
	@echo "  make run             - Ejecutar localmente"
	@echo "  make test            - Ejecutar tests"
	@echo "  make clean           - Limpiar archivos compilados"
	@echo "  make docker-build    - Construir imagen Docker"
	@echo "  make docker-run      - Ejecutar en Docker"
	@echo "  make docker-stop     - Detener contenedor Docker"
	@echo "  make docker-logs     - Ver logs del contenedor"
	@echo "  make docker-clean    - Limpiar contenedores e imágenes"
	@echo "  make deploy          - Desplegar con docker-compose"

build:
	mvn clean package

run:
	mvn spring-boot:run

test:
	mvn test

clean:
	mvn clean

docker-build:
	docker build -t backend-app .

docker-run:
	docker run -d \
		--name backend-container \
		-p 8080:8080 \
		-e DB_IP=localhost \
		-e DB_USER=sa \
		-e DB_PASSWORD=TuPassword123 \
		backend-app

docker-stop:
	docker stop backend-container || true
	docker rm backend-container || true

docker-logs:
	docker logs -f backend-container

docker-clean: docker-stop
	docker rmi backend-app || true

deploy:
	docker-compose up -d

deploy-down:
	docker-compose down

.DEFAULT_GOAL := help

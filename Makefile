FRONT_END_BINARY=frontApp
LOGGER_BINARY=logServiceApp
BROKER_BINARY=brokerApp
AUTH_BINARY=authApp
LISTENER_BINARY=listener
MAIL_BINARY=mailerServiceApp
AUTH_VERSION=1.0.0
BROKER_VERSION=1.0.0
LISTENER_VERSION=1.0.0
MAIL_VERSION=1.0.0
LOGGER_VERSION=1.0.0

## up: запускает все контейнеры в фоновом режиме без принудительной сборки
up:
	@echo "Starting docker images..."
	docker-compose up -d
	@echo "Docker images started!"

## down: остановить docker compose
down:
	@echo "Stopping docker images..."
	docker-compose down
	@echo "Docker stopped!"

## build_dockerfiles: собирает все образы докерфайлов
build_dockerfiles: build_auth build_broker build_listener build_logger build_mail front_end
	@echo "Building dockerfiles..."
	docker build -f front-end.dockerfile -t argoonaut/front-end .
	docker build -f multistage-dockerfiles/authentication-service.dockerfile -t argoonaut/authentication:${AUTH_VERSION} .
	docker build -f multistage-dockerfiles/broker-service.dockerfile -t argoonaut/broker:1.0.0 .
	docker build -f multistage-dockerfiles/listener-service.dockerfile -t argoonaut/listener:1.0.0 .
	docker build -f multistage-dockerfiles/mail-service.dockerfile -t argoonaut/mail:1.0.0 .
	docker build -f multistage-dockerfiles/logger-service.dockerfile -t argoonaut/logger:1.0.0 .

## push_dockerfiles: отправляет отмеченные версии в хаб docker
push_dockerfiles: build_dockerfiles
	docker push argoonaut/authentication:${AUTH_VERSION}
	docker push argoonaut/broker:${BROKER_VERSION}
	docker push argoonaut/listener:${LISTENER_VERSION}
	docker push argoonaut/mail:${MAIL_VERSION}
	docker push argoonaut/logger:${LOGGER_VERSION}
	@echo "Done!"

## front_end: создает исполняемый файл для front-end
front_end:
	@echo "Building front end binary..."
	cd front-end && env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o frontApp ./cmd/web
	@echo "Done!"

## swarm_up: запускает swarm
swarm_up:
	@echo "Starting swarm..."
	docker stack deploy -c swarm.yml myapp

## swarm_down: останавливает swarm
swarm_down:
	@echo "Stopping swarm..."
	docker stack rm myapp

## build_auth: собирает двоичный файл аутентификации как исполняемый файл linux
build_auth:
	@echo "Building authentication binary.."
	cd authentication-service && env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${AUTH_BINARY} ./cmd/api
	@echo "Authentication binary built!"

## build_logger: создает двоичный файл логгера как исполняемый файл linux
build_logger:
	@echo "Building logger binary..."
	cd logger-service && env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${LOGGER_BINARY} ./cmd/web
	@echo "Logger binary built!"

## build_broker: собирает двоичный файл брокера как исполняемый файл linux
build_broker:
	@echo "Building broker binary..."
	cd broker-service && env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${BROKER_BINARY} ./cmd/api
	@echo "Broker binary built!"

## build_listener: собирает двоичный файл слушателя как исполняемый файл linux
build_listener:
	@echo "Building listener binary..."
	cd listener-service && env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${LISTENER_BINARY} .
	@echo "Listener binary built!"

## build_mail: создает почтовый двоичный файл как исполняемый файл linux
build_mail:
	@echo "Building mailer binary..."
	cd mail-service && env GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${MAIL_BINARY} ./cmd/api
	@echo "Mailer binary built!"


## up_build: stops docker-compose (if running), builds all projects and starts docker compose
up_build: build_auth build_broker build_listener build_logger build_mail
	@echo "Stopping docker images (if running...)"
	docker-compose down
	@echo "Building (when required) and starting docker images..."
	docker-compose up --build -d
	@echo "Docker images built and started!"

## auth: останавливает сервис аутентификации, удаляет образ докера, собирает службу и запускает ее
auth: build_auth
	@echo "Building authentication-service docker image..."
	- docker-compose stop authentication-service
	- docker-compose rm -f authentication-service
	docker-compose up --build -d authentication-service
	docker-compose start authentication-service
	@echo "authentication-service built and started!"

## broker: останавливает службу брокера, удаляет образ докера, собирает службу и запускает ее
broker: build_broker
	@echo "Building broker-service docker image..."
	- docker-compose stop broker-service
	- docker-compose rm -f broker-service
	docker-compose up --build -d broker-service
	docker-compose start broker-service
	@echo "broker-service rebuilt and started!"

## logger: останавливает logger-service, удаляет образ docker, собирает сервис и запускает его
logger: build_logger
	@echo "Building logger-service docker image..."
	- docker-compose stop logger-service
	- docker-compose rm -f logger-service
	docker-compose up --build -d logger-service
	docker-compose start logger-service
	@echo "broker-service rebuilt and started!"

## mail: останавливает работу mail-service, удаляет образ docker, собирает сервис и запускает его
mail: build_mail
	@echo "Building mail-service docker image..."
	- docker-compose stop mail-service
	- docker-compose rm -f mail-service
	docker-compose up --build -d mail-service
	docker-compose start mail-service
	@echo "mail-service rebuilt and started!"

## listener: останавливает службу listener-service, удаляет образ докера, собирает службу и запускает ее
listener: build_listener
	@echo "Building listener-service docker image..."
	- docker-compose stop listener-service
	- docker-compose rm -f listener-service
	docker-compose up --build -d listener-service
	docker-compose start listener-service
	@echo "listener-service rebuilt and started!"

## start: запускает front end
start:
	@echo "Starting front end"
	cd front-end && go build -o ${FRONT_END_BINARY} ./cmd/web
	cd front-end && ./${FRONT_END_BINARY} &

## stop: останавливает front end
stop:
	@echo "Stopping front end..."
	@-pkill -SIGTERM -f "./${FRONT_END_BINARY}"
	@echo "Stopped front end!"

## test: выполняет все тесты
test:
	@echo "Testing..."
	go test -v ./...

## clean: запускает go clean и удаляет двоичные файлы
clean:
	@echo "Cleaning..."
	@cd broker-service && rm -f ${BROKER_BINARY}
	@cd broker-service && go clean
	@cd listener-service && rm -f ${LISTENER_BINARY}
	@cd listener-service && go clean
	@cd authentication-service && rm -f ${AUTH_BINARY}
	@cd authentication-service && go clean
	@cd mail-service && rm -f ${MAIL_BINARY}
	@cd mail-service && go clean
	@cd logger-service && rm -f ${LOGGER_BINARY}
	@cd logger-service && go clean
	@cd front-end && go clean
	@cd front-end && rm -f ${FRONT_END_BINARY}
	@echo "Cleaned!"

## help: отображает помощь
help: Makefile
	@echo " Choose a command:"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
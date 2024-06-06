## Запуск проекта
Предполагается, что у вас есть GNU make и Docker.
[GNU make](https://www.gnu.org/software/make/)
[Docker](https://www.docker.com/products/docker-desktop) 

Если вы хотите развернуть микросервисы в yandex cloud, используйте документацию.
[Yandex Cloud](https://yandex.cloud/ru/docs)

К развертыванию в Docker Swarm и Kubernetes есть свои .md файлы.
Некоторые сервисы за комментированы в swarm.yml и для k8s, чтобы проект работал локально.

Запустить микросервисы:

~~~
make up_build 
~~~

Запустить front end:

~~~
make start
~~~

Зайдите через браузер по адресу `http://localhost:80`. Вы также можете получить доступ к 
фронт-энд к службе логгеров, перейдя по адресу `http://localhost:8082` (или по тому порту, который вы
указанный в файле `docker-compose.yml`).

Чтобы остановить все:

~~~
make stop
make down
~~~

Во время работы над кодом вы можете перестроить только ту службу, над которой работаете, ввыполнив команду

`make auth`

Где `auth` - один из сервисов:

- auth
- broker
- logger
- listener
- mail

Все команды: `make help`

~~~
 Choose a command:
  up               starts all containers in the background without forcing build
  down             stop docker compose
  build_auth       builds the authentication binary as a linux executable
  build_logger     builds the logger binary as a linux executable
  build_broker     builds the broker binary as a linux executable
  build_listener   builds the listener binary as a linux executable
  build_mail       builds the mail binary as a linux executable
  up_build         stops docker-compose (if running), builds all projects and starts docker compose
  auth             stops authentication-service, removes docker image, builds service, and starts it
  broker           stops broker-service, removes docker image, builds service, and starts it
  logger           stops logger-service, removes docker image, builds service, and starts it
  mail             stops mail-service, removes docker image, builds service, and starts it
  listener         stops listener-service, removes docker image, builds service, and starts it
  start            starts the front end
  stop             stop the front end
  test             runs all tests
  clean            runs go clean and deletes binaries
  help             displays help
~~~
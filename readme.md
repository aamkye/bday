# BDAY APP !

## Description

This is a RESTFUL app that receives requests from users and is able to show if today is one b-day or when it will be.

## Requirements:

* Docker
* docker-compose (or `docker compose` component)
* Python 3.9+
* virtualenv


## Run env in development mode:

```
./build.sh -btr
```

After running this command docker-compose env will be set up with hot-reload for python changes, so there is no need to rerun stack after changing a few lines.

To get log output:

```
docker logs -f bday-poc_b-day-app_1
docker logs -f bday-poc_mongodb_1
```

Additionally there is `mongo-express` container that allows exploration of mongodb in GUI mode, just click [here](http://localhost:8081/) after starting env.


## Run test automaticly

```
./build.sh -bt -T "all"
./build.sh -bt -T "lint"
./build.sh -bt -T "unit"
./build.sh -bt -T "e2e"
```

## Run tests manually (locally)

First of all you need to setup virtualenv:

```
./local_env.sh
```

Then you have to activate it:

```
source .venv/bin/activate
```

Now you are able to run tests locally.

```
pylint module/ tests/ main.py
pytest -m unit --color=yes
pytest -m e2e --color=yes # while env is up
```

## Run container manually:

```
./build.sh -bt
docker run -it --rm -v $(pwd):/app lodufqa/b-day:latest-dev bash
```

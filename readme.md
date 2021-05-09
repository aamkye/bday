# BDAY APP !

[![Docker build](http://dockeri.co/image/lodufqa/bday)](https://hub.docker.com/r/lodufqa/bday)

***

## Description & diagram

![Diagram](docs/bday.png?raw=true "BDAY Diagram")

***

## Local env

### Requirements:

* Docker
* docker-compose (or `docker compose` component)
* Python 3.9+
* virtualenv
* Terraform (for deployments)

### Run env in development mode:

```
./build.sh -btr
```

After running this command docker-compose env will be set up with hot-reload for python changes, so there is no need to rerun stack after changing a few lines.

To get log output:

```
docker logs -f bday-poc_bday-app_1
docker logs -f bday-poc_mongodb_1
```

Additionally there is `mongo-express` container that allows exploration of mongodb in GUI mode, just click [here](http://localhost:8081/) after starting env.


### Run test automaticly

```
./build.sh -bt -T "all"
./build.sh -bt -T "format"
./build.sh -bt -T "format" -a #autoformat
./build.sh -bt -T "lint"
./build.sh -bt -T "unit"
./build.sh -bt -T "e2e"
```

### Run tests manually (locally)

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
pycodestyle module/ tests/ main.py # just show error
autopep8 --in-place --aggressive --aggressive --recursive --max-line-length=79 module/ tests/ main.py # autoformat
pylint module/ tests/ main.py # linter
pytest -m unit --color=yes # unit tests
pytest -m e2e --color=yes # e2e tests (run while env is up)
```

### Run container manually:

```
./build.sh -bt
docker run -it --rm -v $(pwd):/app lodufqa/bday:latest-dev bash
```

***

## Terraform

### *Initial configs*

To run terraform, you need to create valid configs in `~/.aws/` (terraform uses profile):
* `config`
* `credentials`

Then terraform need first init (unless it has been already done).
This step will create S3 state bucket and dynamodb lockfile.

```
cd ./terraform/init/
terraform init
terraform apply
```

After that you can navigate to upper folder

```
cd ..
```

### *Start here if solutions is already deployed to AWS*

Init actual terraform scripts:

```
terraform init
```

However, before first run you need to create secret file in `./terraform` called `secrets.tfvars` with following structure:

```
dbusername = "<user>"
dbpassword = "<password>"
alb_tls_cert_arn = "<arn>"
```

Now you can safely run:

```
terraform plan -var-file=secrets.tfvars
terraform apply -var-file=secrets.tfvars
```

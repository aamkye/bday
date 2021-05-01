#!/usr/bin/env bash

export PS4='+ $0:$LINENO '
shopt -s extglob
# set -o # Show all options
set -e

###############################################################################
# Variables
PROG_NAME=${0}
PROG_OPTS='bvs'

BUILD_SHELL=0
BUILD_VERBOSE=0
BUILD_TEST=0
BUILD_PUSH=0

DOCKER_IMAGE="b-day"

USAGE="\
Overview:
  Tool for building, preparing and testing environments:
  local, dev, stage and prod, including development purposes.

Program:
  ${PROG_NAME} [${PROG_OPTS}]
"

###############################################################################
# Functions

function error {
  if [[ -n $1 ]]; then
    echo -e "${PROG_NAME}: $1\\n" | fold -s -w80 >&2
  fi
  exit "${2:-1}"
}

function usage {
  echo -e "${USAGE}" | fold -s -w80 >&2
  exit 1
}

function process-opts {
  if [[ "${BUILD_VERBOSE:-''}" -eq "1" ]]; then
    set -fvx
  fi
}

function process-vars {
  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  GIT_SHA=$(git log --pretty=format:'%h' -n 1)
  GIT_DATE=$(git log --pretty=format:'%cI' -n 1)
}

# shellcheck disable=2091
function process-docker-flags {
  if [[ "${BUILD_VERBOSE:-''}" -eq '0' ]]; then
    DOCKER_FLAGS="${DOCKER_FLAGS:-} -q"
  fi
  if [[ "${BUILD_FROM_SCRATCH:-''}" -eq '1' ]]; then
    DOCKER_FLAGS="${DOCKER_FLAGS:-} --no-cache"
  fi
}

# build-image "final"
# shellcheck disable=2046,2086
function build-image {
  # Make new line if docker does silent build
  if [[ "${BUILD_VERBOSE:-''}" -lt '2' ]]; then
    echo
  fi

  if [[ "${BUILD_SHELL:-'0'}" -ge "0" ]]; then
    docker build -f "./dockerfile" ${DOCKER_FLAGS:-} \
      --build-arg GIT_SHA="${GIT_SHA:-''}" \
      --build-arg GIT_BRANCH="${GIT_BRANCH:-''}" \
      --build-arg GIT_DATE="${GIT_DATE:-''}" \
      --build-arg BUILD_DATE="$(date --iso-8601=seconds)" \
      . \
      -t "${DOCKER_IMAGE}/app:latest"

    docker tag \
      "${DOCKER_IMAGE}/app:latest" \
      "${DOCKER_IMAGE}/app:${GIT_SHA}"
  fi
}

function run-tests {
  true
}

# shellcheck disable=2046,2086
function process-build {
  process-docker-flags
  if [[ "${BUILD_SHELL:-'0'}" -eq "1" ]]; then
    build-image
  elif [[ "${BUILD_TEST:-'0'}" -eq "1" ]]; then
    run-tests
  fi
}

function push-image {
  docker push "${DOCKER_IMAGE}/app:${1}" >&2
}

function process-push {
  if [[ "${BUILD_PUSH:-'0'}" -eq "1" ]]; then
    push-image "latest"
    push-image "${GIT_SHA}"
  fi
}

###############################################################################
# Main script
# shellcheck disable=2034
while getopts ${PROG_OPTS} c
do
  case ${c} in
    b) BUILD_SHELL=1 ;;
    v) BUILD_VERBOSE=1 ;;
    s) BUILD_FROM_SCRATCH=1 ;;
    t) BUILD_TEST=1 ;;
    p) BUILD_PUSH=1 ;;
    :) error "missing argument for -- '${OPTARG}'" 1 ;;
    *) error "invalid option -- '${OPTARG}'" 2 ;; esac
done


process-opts
process-vars
process-build
process-push

###############################################################################

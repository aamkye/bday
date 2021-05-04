#!/usr/bin/env bash

export PS4='+ $0:$LINENO '
shopt -s extglob
# set -o # Show all options
set -e

###############################################################################
# Variables
PROG_NAME=${0}
PROG_OPTS=':bvstprhT:'

BUILD_SHELL=0
BUILD_VERBOSE=0
BUILD_TEST=0
BUILD_PUSH=0
BUILD_FROM_SCRATCH=0
BUILD_RUN=0
TEST_TYPE=""

DOCKER_IMAGE="lodufqa/b-day"

USAGE="\
Overview:
  Tool for building, preparing, testing and pushing docker images.

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
  local TARGET
  if [[ "${BUILD_SHELL:-'0'}" -eq "1" ]]; then
    if [[ "${BUILD_TEST:-'0'}" -eq "0" ]]; then
      TARGET="final"
    else
      TARGET="dev"
    fi
    docker build -f "./dockerfile" ${DOCKER_FLAGS:-} \
      --target "${TARGET}" \
      --build-arg GIT_SHA="${GIT_SHA:-''}" \
      --build-arg GIT_BRANCH="${GIT_BRANCH:-''}" \
      --build-arg GIT_DATE="${GIT_DATE:-''}" \
      . \
      -t "${DOCKER_IMAGE}:${GIT_SHA}"

    if [[ "${BUILD_TEST:-'0'}" -eq "0" ]]; then
      docker tag \
        "${DOCKER_IMAGE}:${GIT_SHA}" \
        "${DOCKER_IMAGE}:latest"
    else
      docker tag \
        "${DOCKER_IMAGE}:${GIT_SHA}" \
        "${DOCKER_IMAGE}:latest-dev"
    fi

  fi
}

function run-tests {
    if [[ "${TEST_TYPE:-''}" == "lint" || "${TEST_TYPE:-''}" == 'all' ]]; then
      docker run --rm -v $(pwd):/app "${DOCKER_IMAGE}":latest-dev pylint module/ tests/ main.py
    fi
    if [[ "${TEST_TYPE:-''}" == "unit" || "${TEST_TYPE:-''}" == 'all' ]]; then
      docker run --rm -v $(pwd):/app "${DOCKER_IMAGE}":latest-dev pytest -m unit --color=yes
    fi
    if [[ "${TEST_TYPE:-''}" == "e2e" || "${TEST_TYPE:-''}" == 'all' ]]; then
      docker-compose down --remove-orphans || true
      docker-compose up -d
      docker run --rm -v $(pwd):/app --net=host "${DOCKER_IMAGE}":latest-dev pytest -m e2e --color=yes
      docker-compose down --remove-orphans
    fi
}

function run-env {
  docker-compose down --remove-orphans && \
    docker-compose up && \
    docker-compose down --remove-orphans
}

# shellcheck disable=2046,2086
function process-build {
  process-docker-flags
  if [[ "${BUILD_SHELL:-'0'}" -eq "1" ]]; then
    build-image
  fi
}

function process-run {
  if [[ "${BUILD_TEST:-'1'}" -eq "1" && -n TEST_TYPE ]]; then
    run-tests
  fi
  if [[ "${BUILD_RUN:-'0'}" -eq "1" ]]; then
    run-env
  fi
}

function push-image {
  docker push "${DOCKER_IMAGE}:${1}" >&2
}

function process-push {
  if [[ "${BUILD_PUSH:-'0'}" -eq "1" ]]; then
    docker login
    push-image "latest" || true
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
    T) TEST_TYPE="${OPTARG}" ;;
    p) BUILD_PUSH=1 ;;
    r) BUILD_RUN=1 ;;
    h) usage ;;
    :) error "missing argument for -- '${OPTARG}'" 1 ;;
    *) error "invalid option -- '${OPTARG}'" 2 ;; esac
done

process-opts
process-vars
process-build
process-run
process-push

###############################################################################

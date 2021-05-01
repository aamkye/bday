FROM python:3.9-slim as base
LABEL maintainer="Amadeusz Kryze <amadeusz.kryze@tieto.com>"
ENV PYTHONUNBUFFERED=1
ENV PYTHONHASHSEED=0
ENV PYTHONDONTWRITEBYTECODE=1
WORKDIR /app
RUN apt update && apt install -y sudo apt-transport-https && \
  groupadd -g 1000 -r app_group && useradd -m -r -g app_group -u 1000 app && \
  chown app:app_group /app && \
  apt install -y --allow-unauthenticated --no-install-recommends \
  dumb-init && \
  rm -rf /var/lib/apt/lists/*
USER app
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

FROM base AS reqs
WORKDIR /tmp
COPY --chown=app:app_group ./requirements.txt /tmp
RUN pip3 install --user -r /tmp/requirements.txt

FROM reqs AS final
ARG com.b-day.git.sha
ARG com.b-day.git.branch
ARG com.b-day.git.date
ARG com.b-day.build.date
LABEL com.b-day.git.sha="${GIT_SHA}"
LABEL com.b-day.git.branch="${GIT_BRANCH}"
LABEL com.b-day.git.date="${GIT_DATE}"
LABEL com.b-day.build.date="${BUILD_DATE}"
WORKDIR /app
COPY --chown=app:app_group ./ /app
CMD [ "python", "main.py" ]

FROM final AS dev
WORKDIR /tmp
COPY --chown=app:app_group ./requirements-dev.txt /tmp
RUN pip3 install --user -r /tmp/requirements-dev.txt
WORKDIR /app

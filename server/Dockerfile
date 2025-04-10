FROM mcr.microsoft.com/mirror/docker/library/python:3.11-slim as builder

RUN pip install poetry==1.7.1

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app
COPY ./server/pyproject.toml ./server/poetry.lock ./
# poetry needs a README.md to build the project
RUN touch README.md 

RUN poetry install && rm -rf $POETRY_CACHE_DIR

FROM mcr.microsoft.com/mirror/docker/library/python:3.11-slim as runtime

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    gpg \
    gnupg2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && apt-get install -y azure-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY ./server .
RUN pip install --no-cache-dir ./dist/*.whl

COPY ./lib lib

CMD ["bash", "run.sh"]

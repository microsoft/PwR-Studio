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

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY ./server .
RUN pip install --no-cache-dir ./dist/*.whl

COPY ./lib lib


CMD ["uvicorn", "app.main:app", "--reload", "--host", "0.0.0.0", "--port", "3000"]

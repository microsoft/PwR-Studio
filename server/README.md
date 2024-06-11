# PbyC Server

This server acts like a middleware between the user interface and the PbyC library / engine.

It exposese a few API endpoints (see swagger [/docs](http://pbyc-server-v2-ftpq.southindia.azurecontainer.io:3000/docs)) and websockets for the chat.

## How to run

### Using Docker Compose
```
$docker compose build

# Setup the .env file with secrets
$cat server/.env

# Run server in development mode
$docker compose --env-file server/.env up
```
### Doing it from scratch
```
$cd server

# create a virtual environment and install the dependencies
$python3 -m venv .venv
$source .venv/bin/activate
$pip install -r requirements.txt

$echo "DB_CONNECTION_STRING=" > .env


# update the database using alembic
$cd app
$alembic upgrade head

# run the server
$uvicorn app.main:app --reload

# to deactivate the virtual environment
$deactivate

```

## Populate data using the Swagger UI 

In the browser go to [http://localhost:8000/docs](http://localhost:8000/docs) and use the endpoints to populate the database.

## Creating a revision for the database

We use Alembic to track changes to the database. To create a new revision, run the following command:

```
$cd app
$alembic revision --autogenerate -m "short description of the change"
$ls -lrt alembic/versions
```

View the changes made in the new version file and then run the following command to update the database:

```
$cd app
$alembic upgrade head
```

## Build via Docker

```
$cd .. #At PbyC level
$docker build . -t pbyc-server-v2
$docker run -it --env-file server/.env pbyc-server-v2

```

## Environment Variables / Secrets
Create a file at server/.env
```
DB_CONNECTION_STRING=
OPENAI_API_KEY=
PBYC_SIMPLE_BOT_OUTPUT_URL=
PBYC_SIMPLE_BOT_EXPORT_URL=
SERPAPI_API_KEY=
PBYC_SIMPLE_PYTHON_OUTPUT_URL=
PBYC_SIMPLE_PYTHON_EXPORT_URL=
```


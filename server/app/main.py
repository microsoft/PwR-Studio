from openai import OpenAI
import logging
import time
from jwt.exceptions import InvalidSignatureError
import jwt
from .utils import generate_q_message
import requests
import uuid
import json
import os
from typing import List, Optional
from fastapi import (
    FastAPI,
    Request,
    HTTPException,
    Depends,
    WebSocket,
    File,
    UploadFile,
    WebSocketDisconnect,
    Body,
    Form,
)
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import lib.pwr_studio.types as pwr_schema
from . import crud, models, schemas
from .database import SessionLocal
from .chat_manager import ChatConnectionManager
import tempfile
from dotenv import load_dotenv
from lib.pwr_studio.kafka_utils import KafkaProducer

load_dotenv()

logger = logging.getLogger(__name__)
logger.setLevel(level=logging.INFO)

devChatManager = ChatConnectionManager()
outputChatManager = ChatConnectionManager()

producer = KafkaProducer.from_env_vars()


SERVER_HOST = os.environ["SERVER_HOST"]

app = FastAPI()
user_id = None
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


public_keys = {}
AAD_APP_CLIENT_ID = os.environ["AAD_APP_CLIENT_ID"]
AAD_APP_TENANT_ID = os.environ["AAD_APP_TENANT_ID"]
ISSUER = f'https://login.microsoftonline.com/{AAD_APP_TENANT_ID}/v2.0'
JWKS_URI = f'https://login.microsoftonline.com/{AAD_APP_TENANT_ID}/discovery/v2.0/keys'


def authenticate_id_token(id_token, issuer, audience, jwks_uri):
    # Create a JWKS client
    jwks_client = jwt.PyJWKClient(jwks_uri)
    
    # Get the signing key
    signing_key = jwks_client.get_signing_key_from_jwt(id_token)
    
    # Decode and validate the token
    decoded_token = jwt.decode(
        id_token,
        signing_key.key,
        algorithms=["RS256"],
        audience=audience,
        # issuer=issuer
        options={"verify_aud": True, "verify_iss": False},
    )
    return decoded_token

async def verify_jwt(token):
    try:
        id_token = token.replace("Bearer ", "")
        return authenticate_id_token(id_token, ISSUER, AAD_APP_CLIENT_ID, JWKS_URI)
        # TODO: Fix auth
    except Exception as e:
        print("Auth error:", e)
        return None


async def get_moderation_chat(user_message: str):
    try:
        client = OpenAI(
            api_key=os.environ["OPENAI_API_KEY"],
        )
        response = client.moderations.create(input=user_message)

        # Checking if any flags are raised
        if response.results and response.results[0].flagged == True:
            return True, "Please check your language, do not use any abusive words"
        else:
            return False, "No flags raised"

    except Exception as e:
        # Handle any errors in the API call or processing
        print(f"An error occurred: {e}")


async def trigger_dsl_import(dsl: UploadFile, db: Session, db_project: models.Project):
    dsl.file.seek(0)
    contents = dsl.file.read()
    crud.create_representation(
        db,
        representation_dict={
            "name": "dsl",
            "text": contents.decode("utf-8"),
            "type": "md",
            "sort_order": 2,
            "project_id": db_project.id,
        },
    )
    correlation_id = str(uuid.uuid4())
    q_message = generate_q_message(
        db,
        "import",
        project_id=db_project.id,
        session_id=str(uuid.uuid4()),
        utterance="initializing the project with dsl import",
        credentials={},
        engine_url=None,
        response_url=f"{SERVER_HOST}/projects/{db_project.id}/chat/response",
        correlation_id=correlation_id,
    )

    logger.info(f"#1Sb - main.py Sending via HTTP; PwR-RID={correlation_id}")
    await send_message_to_function(
        q_message["engine_name"], q_message, correlation_id=correlation_id
    )


@app.middleware("http")
async def add_process_time_header(req: Request, call_next):
    # TODO: skipping queue webhooks
    path = req.url.path
    if (
        req.method == "OPTIONS"
        or path.endswith("/docs")
        or path.endswith("/openapi.json")
        or path.endswith("/chat/response")
        or path.endswith("/output/response")
    ):
        response = await call_next(req)
        return response
    if not "authorization" in req.headers:
        return JSONResponse(status_code=401, content="")
    try:
        token = req.headers["authorization"]
        verification_of_token = await verify_jwt(token)

        if verification_of_token:
            user_id = verification_of_token["oid"]
            req.state.oid = user_id
            response = await call_next(req)
            return response
        else:
            return JSONResponse(status_code=403, content="")
    except InvalidSignatureError as er:
        return JSONResponse(status_code=401, content="")


@app.post(
    "/users",
)
async def save_user_if_not_found(
    user: schemas.UserCreate, db: Session = Depends(get_db)
):
    if not crud.get_user(db, user.oid):
        crud.create_user(db, user)
    return JSONResponse(status_code=200, content="User saved/updated")


@app.get("/error_states/{pid}")
async def get_error_states(pid: int, db: Session = Depends(get_db)):
    # return crud.get_error_states(db, pid)
    # TODO fix db
    return []


@app.get("/templates", response_model=List[schemas.Template])
async def all_templates(skip: int = 0, limit: int = 20, db: Session = Depends(get_db)):
    return crud.get_templates(db, skip=skip, limit=limit) or []


@app.get("/templates/{id}", response_model=schemas.Template)
async def get_template(id: int, db: Session = Depends(get_db)):
    template = crud.get_template(db, template_id=id)
    if template is None:
        raise HTTPException(status_code=404, detail="Template not found")
    return template


@app.post("/templates", response_model=schemas.Template)
def create_template(template: schemas.TemplateCreate, db: Session = Depends(get_db)):
    return crud.create_template(db, template=template)


@app.put("/templates/{id}", response_model=schemas.Template)
async def update_template(
    id: int, template: schemas.TemplateCreate, db: Session = Depends(get_db)
):
    template = crud.get_template(db, template_id=id)
    if template is None:
        raise HTTPException(status_code=404, detail="Template not found")
    return crud.update_template(db, template_id=id, template=template)


@app.post("/projects", response_model=schemas.Project)
async def create_project(
    template_id: int,
    req: Request,
    name: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    project_class: Optional[str] = Form(None),
    dsl: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
):

    template_project = crud.get_template(db, template_id=template_id)
    if template_project is None:
        raise HTTPException(status_code=404, detail="Template not found")

    project_credentials = [
        schemas.ProjectCredentialCreate(
            name=credential.name,
            description=credential.description,
            mandatory=credential.mandatory,
        )
        for credential in template_project.TemplateCredentials
    ]
    updated_project = schemas.ProjectCreate(
        name=name,
        description=description or template_project.description,
        project_class=project_class,
        engine_url=template_project.engine_url,
        file_upload=template_project.file_upload,
        audio_upload=template_project.audio_upload,
        has_credentials=template_project.has_credentials,
        credentials=project_credentials,
        users=[schemas.ProjectUserCreate(oid=req.state.oid)],
    )

    db_project = crud.create_project(db, project=updated_project)
    representations = []
    if project_class == "jb_app" and dsl is not None:
        await trigger_dsl_import(dsl, db, db_project)

    return db_project


@app.post("/import_dsl/{pid}")
async def import_dsl(
    pid: int, dsl: UploadFile = File(...), db: Session = Depends(get_db)
):
    project = crud.get_project(db, project_id=pid)
    if project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    if dsl is not None:
        await trigger_dsl_import(dsl, db, project)
    return JSONResponse(status_code=200, content="Imported DSL successfully")


@app.get("/projects", response_model=List[schemas.Project])
async def all_projects(
    req: Request, skip: int = 0, limit: int = 10, db: Session = Depends(get_db)
):
    projects = crud.get_projects_for_user(db, req.state.oid) or []
    return projects


@app.post("/projects/import", response_model=schemas.Project)
async def import_project(
    project: schemas.ProjectImport, req: Request, db: Session = Depends(get_db)
):
    import_project = schemas.ProjectCreate(
        name=project.name,
        description=project.description,
        project_class=project.project_class,
        engine_url=project.engine_url,
        file_upload=project.file_upload,
        audio_upload=project.audio_upload,
        has_credentials=project.has_credentials,
        credentials=project.credentials,
        users=[schemas.ProjectUserCreate(oid=req.state.oid)],
        representations=project.representations,
    )

    db_project = crud.import_project(db, project=import_project)

    return db_project


@app.get("/templates/{project_class}/plugins")
async def get_plugins(project_class: str, db: Session = Depends(get_db)):
    return crud.get_plugins(db, project_class=project_class)


@app.get("/projects/{id}", response_model=schemas.Project)
async def get_project(id: int, req: Request, db: Session = Depends(get_db)):
    project = crud.get_project(db, project_id=id)
    if project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    project_user = crud.get_project_user(db, project_id=id, oid=req.state.oid)
    if project_user is None:
        return JSONResponse(status_code=403, content="Forbidden to access project")
    return project


@app.put("/projects/{id}", response_model=schemas.Project)
async def update_project(
    id: int, req: Request, project: schemas.ProjectCreate, db: Session = Depends(get_db)
):
    project = crud.get_project(db, project_id=id)
    if project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    project_user = crud.get_project_user(db, project_id=id, oid=req.state.oid)
    if project_user is None:
        return JSONResponse(status_code=403, content="Forbidden to access project")
    return crud.update_project(db, project_id=id, project=project)


@app.post(
    "/projects/{id}/share",
)
async def share_project(
    id: int,
    req: Request,
    db: Session = Depends(get_db),
    user: dict = Body(..., example={"email": "test@example.com"}),
):
    userData = crud.get_user_by_email(db, user.get("email"))
    if not userData:
        return JSONResponse(
            status_code=400,
            content={"message": "Please ask the user to sign up at PbyC first"},
        )
    if userData.oid == req.state.oid:
        return JSONResponse(
            status_code=400,
            content={"message": "You cannot share project with yourself"},
        )

    crud.create_project_user(
        db, project_user_dict={"oid": userData.oid, "project_id": id}
    )

    return JSONResponse(
        status_code=200, content={"message": f"Project Shared to {user.get('email')}"}
    )


@app.get("/projects/{id}/chat", response_model=List[schemas.ChatMessage])
async def get_project_chat(
    id: int, req: Request, skip: int = 0, limit: int = 10, db: Session = Depends(get_db)
):
    project_user = crud.get_project_user(db, project_id=id, oid=req.state.oid)
    if project_user is None:
        return JSONResponse(status_code=403, content="Forbidden to access project")
    return crud.get_chat_messages(db, project_id=id, skip=skip, limit=limit)


@app.get("/projects/{pid}/representations")
async def get_representation_values(
    pid: int, req: Request, db: Session = Depends(get_db)
):
    project_user = crud.get_project_user(db, project_id=pid, oid=req.state.oid)
    if project_user is None:
        return JSONResponse(status_code=403, content="Forbidden to access project")
    return crud.get_representations(db, project_id=pid)


@app.post("/projects/{pid}/export")
async def project_export_api(
    pid: int, message: schemas.ChatMessageWithCredentials, db: Session = Depends(get_db)
):
    if not message.session_id:
        message.session_id = str(uuid.uuid4())

    start = time.time()
    correlation_id = str(uuid.uuid4())
    message.response_url = f"{SERVER_HOST}/projects/{pid}/chat/response"

    logger.info(f"#1S - main.py Starting Export; PwR-RID={correlation_id}")
    q_message = generate_q_message(
        db,
        "export",
        project_id=pid,
        session_id=message.session_id,
        utterance=message.message,
        credentials=message.credentials,
        engine_url=message.engine_url,
        response_url=message.response_url,
        correlation_id=correlation_id,
    )

    # print(q_message)

    chat_message = {
        "type": message.type,
        "session_id": message.session_id,
        "sender": "user",
        "sender_id": "User:",
        "message": message.message,
        "project_id": pid,
    }

    # Save the chat message to the database
    crud.create_chat_message(db, chat_message)

    logger.info(f"#1Sb - main.py Sending via HTTP; PwR-RID={correlation_id}")
    await send_message_to_function(
        q_message["engine_name"], q_message, correlation_id=correlation_id
    )
    end = time.time()
    logger.info(
        f"#1E - main.py Completed in {end - start} seconds message in Q with {message.message}; PwR-RID={correlation_id}"
    )
    return {"message": "Message received", "session_id": message.session_id}


@app.post("/projects/{pid}/chat")
async def project_chat_api(pid: int, message: schemas.ChatMessageWithCredentials):
    if not message.session_id:
        message.session_id = str(uuid.uuid4())

    start = time.time()
    correlation_id = str(uuid.uuid4())
    message.response_url = (
        f"{SERVER_HOST}/projects/{pid}/chat/response?webhook={message.webhook}"
    )

    logger.info(
        f"#1S - main.py Starting Utterance with {message.message}; PwR-RID={correlation_id}"
    )
    await process_websocket_message(pid, message.session_id, message, correlation_id)
    end = time.time()
    logger.info(
        f"#1E - main.py Completed in {end - start} seconds message in Q with {message.message}; PwR-RID={correlation_id}"
    )
    return {"message": "Message received", "session_id": message.session_id}


@app.websocket("/projects/{pid}/chat")
async def project_chat(websocket: WebSocket, pid: int):
    await devChatManager.connect(pid, websocket)
    session_id = str(uuid.uuid4())
    try:
        while True:
            data = await websocket.receive_text()

            start = time.time()
            correlation_id = str(uuid.uuid4())
            message = schemas.ChatMessageWithCredentials.parse_obj(json.loads(data))
            message_flagged, moderation_message = (
                False,
                "",
            )  # await get_moderation_chat(message.message)
            if message_flagged:
                await devChatManager.send_message_for_project_id(
                    json.dumps({"type": "error", "message": moderation_message}), pid
                )
                continue
            message.response_url = f"{SERVER_HOST}/projects/{pid}/chat/response"

            logger.info(
                f"#1S - main.py Starting Utterance with {message.message}; PwR-RID={correlation_id}"
            )
            await process_websocket_message(pid, session_id, message, correlation_id)
            end = time.time()
            logger.info(
                f"#1E - main.py Completed in {end - start} seconds message in Q with {message.message}; PwR-RID={correlation_id}"
            )
    except WebSocketDisconnect:
        devChatManager.disconnect(websocket)


db_session = SessionLocal()


async def process_websocket_message(
    pid: int,
    session_id: str,
    message: schemas.ChatMessageWithCredentials,
    correlation_id: str,
):

    with db_session as db:
        if message.type == "feedback" and "\x1f" in message.message:
            messages = message.message.split("\x1f")
            parent_message = messages[0]
            reply_message = messages[1]
            # TODO: should we check feedback type here
            message.message = (
                "I dont like the following response given by the chatbot: "
                + parent_message
                + ". Make appropriate changes to take into account the following: "
                + reply_message
            )

        q_message = generate_q_message(
            db,
            "utterance",
            project_id=pid,
            session_id=session_id,
            utterance=message.message,
            credentials=message.credentials,
            engine_url=message.engine_url,
            response_url=message.response_url,
            correlation_id=correlation_id,
        )

        # print(q_message)

        chat_message = {
            "type": message.type,
            "session_id": session_id,
            "sender": "user",
            "sender_id": "User:",
            "message": message.message,
            "project_id": pid,
        }

        # Save the chat message to the database
        crud.create_chat_message(db, chat_message)

    print(q_message)

    logger.info(f"#1Sb - main.py Sending via HTTP; PwR-RID={correlation_id}")
    await send_message_to_function(
        q_message["engine_name"], q_message, correlation_id=correlation_id
    )


async def send_message_to_function(
    queue_name: str, q_message: dict, correlation_id=None
):
    result = True
    print(queue_name)
    if queue_name == "custom":
        producer.send_message(
            os.environ["KAFKA_CUSTOM_TOPIC"], value=json.dumps(q_message)
        )
    elif queue_name == "jb_app":
        producer.send_message(os.environ["KAFKA_ENGINE_TOPIC"], value=json.dumps(q_message))
    else:
        raise Exception(f"Invalid project_class name {queue_name}")

    return result


@app.post("/projects/{pid}/chat/upload")
async def dev_upload(
    pid: int,
    files: List[UploadFile] = File(...),
    webhook: Optional[str] = Form(None),
    engine_url: Optional[str] = Form(None),
    credentials: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):

    fileList: List[pwr_schema.File] = []
    fileNames = []
    if credentials is not None:
        credentials = json.loads(credentials)
    response_url = f"{SERVER_HOST}/projects/{pid}/chat/response"
    if webhook is not None:
        response_url = f"{SERVER_HOST}/projects/{pid}/chat/response?webhook={webhook}"
    with tempfile.TemporaryDirectory() as tmpdir:
        for file in files:
            file.file.seek(0)
            contents = file.file.read()
            unique_filename = str(uuid.uuid4()) + os.path.splitext(file.filename)[1]
            fileNames.append(file.filename + " - " + unique_filename)
            with open(os.path.join(tmpdir, unique_filename), "wb") as f:
                f.write(contents)

            # upload to blob storage and SAS URL

            blobManager.upload_file(
                os.path.join(tmpdir, unique_filename), unique_filename
            )

            fileList.append(
                pwr_schema.File(
                    name=file.filename + " - " + unique_filename,
                    type=file.content_type,
                    url=blobManager.get_url(unique_filename),
                )
            )

    # print(urls)

    with SessionLocal() as db:
        q_message = generate_q_message(
            db,
            "utterance",
            project_id=pid,
            engine_url=engine_url,
            response_url=response_url,
            credentials=credentials,
            files=fileList,
        )
        crud.create_chat_message(
            db,
            {
                "type": "files",
                "sender": "user",
                "sender_id": "User:",
                "session_id": None,
                "message": "Uploaded files: " + ", ".join(fileNames),
                "project_id": pid,
            },
        )
        db.close()

    if not await send_message_to_function(q_message["engine_name"], q_message):
        return {"error": "Failed to write message to Q. Please try again"}
    else:
        return {"success": "Message written to Q"}


@app.post("/projects/{pid}/output")
async def project_output_api(pid: int, message: schemas.ChatMessageWithCredentials):
    if not message.session_id:
        message.session_id = str(uuid.uuid4())

    start = time.time()
    correlation_id = str(uuid.uuid4())
    message.response_url = (
        f"{SERVER_HOST}/projects/{pid}/output/response?webhook={message.webhook}"
    )

    logger.info(
        f"#1S - main.py Starting Output with {message.message}; PwR-RID={correlation_id}"
    )
    with SessionLocal() as db:
        q_message = generate_q_message(
            db,
            "output",
            response_url=message.response_url,
            engine_url=message.engine_url,
            project_id=pid,
            correlation_id=correlation_id,
            credentials=message.credentials,
            utterance=message.message,
            project=None,
            session_id=message.session_id,
        )
        crud.create_output_message(
            db,
            {
                "type": message.type,
                "sender": "user",
                "session_id": message.session_id,
                "message": message.message,
                "project_id": pid,
            },
        )
        db.close()
    if not await send_message_to_function(
        q_message["engine_name"], q_message, correlation_id=correlation_id
    ):
        return {"type": "error", "message": "Not able to write to queue"}
        end = time.time()
        logger.info(
            f"#1E - main.py Failed in {end - start} seconds message in Q with {message.message}; PwR-RID={correlation_id}"
        )
    else:
        end = time.time()
        logger.info(
            f"#1E - main.py Completed successfully in {end - start} seconds message in Q with {message.message}; PwR-RID={correlation_id}"
        )
    return {"message": "Message received", "session_id": message.session_id}


@app.websocket("/projects/{pid}/output")
async def project_chat(websocket: WebSocket, pid: int):
    await outputChatManager.connect(pid, websocket)
    session_id = str(uuid.uuid4())
    try:
        while True:
            start = time.time()
            data = await websocket.receive_text()
            correlation_id = str(uuid.uuid4())
            message = schemas.ChatMessageWithCredentials.parse_obj(json.loads(data))
            message_flagged, moderation_message = (
                False,
                "",
            )  # await get_moderation_chat(message.message)
            if message_flagged:
                await outputChatManager.send_message_for_project_id(
                    json.dumps({"type": "error", "message": moderation_message}), pid
                )
                continue
            message.response_url = f"{SERVER_HOST}/projects/{pid}/output/response"
            logger.info(
                f"#1S - main.py Starting Output with {message.message}; PwR-RID={correlation_id}"
            )

            with SessionLocal() as db:
                q_message = generate_q_message(
                    db,
                    "output",
                    response_url=message.response_url,
                    engine_url=message.engine_url,
                    project_id=pid,
                    correlation_id=correlation_id,
                    credentials=message.credentials,
                    utterance=message.message,
                    project=None,
                    session_id=session_id,
                )
                crud.create_output_message(
                    db,
                    {
                        "type": message.type,
                        "sender": "user",
                        "session_id": session_id,
                        "message": message.message,
                        "project_id": pid,
                    },
                )
                db.close()

            if not await send_message_to_function(
                q_message["engine_name"], q_message, correlation_id=correlation_id
            ):
                await outputChatManager.send_message(
                    "{'type':'error','message':'Failed to write message to Q. Please try again'}",
                    websocket,
                )
                end = time.time()
                logger.info(
                    f"#1E - main.py Failed in {end - start} seconds message in Q with {message.message}; PwR-RID={correlation_id}"
                )
            else:
                end = time.time()
                logger.info(
                    f"#1E - main.py Completed successfully in {end - start} seconds message in Q with {message.message}; PwR-RID={correlation_id}"
                )
    except WebSocketDisconnect:
        outputChatManager.disconnect(websocket)


@app.post("/projects/{pid}/output/upload")
async def output_upload(
    pid: int,
    files: List[UploadFile] = File(...),
    engine_url: Optional[str] = Form(None),
    credentials: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    urls = []
    fileList: List[pwr_schema.File] = []

    if credentials is not None:
        credentials = json.loads(credentials)

    response_url = f"{SERVER_HOST}/projects/{pid}/output/response"
    with tempfile.TemporaryDirectory() as tmpdir:
        for file in files:
            file.file.seek(0)
            contents = file.file.read()

            unique_filename = str(uuid.uuid4()) + os.path.splitext(file.filename)[1]

            with open(os.path.join(tmpdir, unique_filename), "wb") as f:
                f.write(contents)

            # upload to blob storage and SAS URL

            blobManager.upload_file(
                os.path.join(tmpdir, unique_filename), unique_filename
            )

            fileList.append(
                pwr_schema.File(
                    name=file.filename + " - " + unique_filename,
                    type=file.content_type,
                    url=blobManager.get_url(unique_filename),
                )
            )

    with SessionLocal() as db:
        q_message = generate_q_message(
            db,
            "utterance",
            project_id=pid,
            response_url=response_url,
            engine_url=engine_url,
            credentials=credentials,
            project=None,
            files=fileList,
        )
        db.close()

    if not await send_message_to_function(q_message["engine_name"], q_message):
        return {"error": "Failed to write message to Q. Please try again"}
    else:
        return {"success": "Message written to Q"}


@app.post(
    "/log",
)
async def save_analytics_log(
    analytics_log: schemas.AnalyticsLogCreate, db: Session = Depends(get_db)
):
    crud.create_analytics_log(db, analytics_log=analytics_log)
    return {"success": "Log written to queue"}


# Define the response_model here
@app.post("/projects/{project_id}/take_edit")
async def take_edit(
    project_id: int, message: schemas.TakeEditBase, db: Session = Depends(get_db)
):
    start = time.time()
    correlation_id = str(uuid.uuid4())
    logger.info(
        f"#1S - main.py Starting representation_edit with {message.changed_representation.name}; PwR-RID={correlation_id}"
    )
    response_url = f"{SERVER_HOST}/projects/{project_id}/chat/response"
    if message.webhook is not None:
        response_url = f"{SERVER_HOST}/projects/{project_id}/chat/response?webhook={message.webhook}"
    crud.create_chat_message(
        db,
        {
            "type": "representation_edit",
            "sender": "user",
            "sender_id": "User:",
            "session_id": None,
            "message": json.dumps(message.changed_representation.dict()),
            "project_id": project_id,
        },
    )
    q_message = generate_q_message(
        db,
        "representation_edit",
        project_id=project_id,
        credentials=message.credentials,
        engine_url=message.engine_url,
        response_url=response_url,
        correlation_id=correlation_id,
        changed_representation=message.changed_representation,
    )

    if not await send_message_to_function(q_message["engine_name"], q_message):
        end = time.time()
        logger.info(
            f"#1E - main.py Failed in {end - start} seconds message in Q with represenation_edit; PwR-RID={correlation_id}"
        )
        return {"error": "Failed to write message to Q. Please try again"}
    else:
        end = time.time()
        logger.info(
            f"#1E - main.py Completed succesfully in {end - start} seconds message in Q with representation_edit PwR-RID={correlation_id}"
        )
        return {"success": "Message written to Q"}


@app.delete("/projects/{pid}")
async def delete_project(pid: int, db: Session = Depends(get_db)):
    crud.delete_project(db, pid)
    return {"success": "Project deleted"}


@app.post("/projects/{pid}/chat/response")
async def get_chat_response(
    pid: int,
    dev_response: pwr_schema.Response,
    webhook: str = None,
    db: Session = Depends(get_db),
):

    start = time.time()
    correlation_id = dev_response.correlation_id
    logger.info(
        f"#3S - main.py Starting Webhook with {dev_response.type}:{dev_response.message}; PwR-RID={correlation_id}"
    )

    if dev_response.project:
        project = dev_response.project
        # if project.current_iteration:
        #     iterations_row['description'] = project.current_iteration.description

        for name in project.representations:
            representation = project.representations[name]
            rep_dict = {
                "name": name,
                "type": representation.type,
                "text": representation.text,
                "project_id": pid,
                "is_pwr_viewable": representation.is_pwr_viewable,
                "is_user_viewable": True,
                "is_editable": representation.is_editable,
                "sort_order": representation.sort_order,
            }
            crud.create_representation(db, rep_dict)

    crud.create_chat_message(
        db,
        {
            "type": dev_response.type,
            "sender": "bot",
            "session_id": dev_response.session_id,
            "message": dev_response.message,
            "project_id": pid,
        },
    )

    text = json.dumps(dev_response.dict())

    if not webhook:
        await devChatManager.send_message_for_project_id(text, pid)
    else:
        requests.post(webhook, data=text)

    end = time.time()
    logger.info(
        f"#3E - main.py Completed in {end - start} seconds message in Webhook with {dev_response.type}:{dev_response.message}; PwR-RID={correlation_id}"
    )
    return {"message": "ok"}


@app.post("/projects/{pid}/output/response")
async def get_output_response(
    pid: int,
    output_response: pwr_schema.Response,
    webhook: str = None,
    db: Session = Depends(get_db),
):
    text = json.dumps(output_response.dict())
    start = time.time()
    print(
        f"#3S - main.py Starting Output Webhook with {output_response.type}:{output_response.message}; PwR-RID={output_response.correlation_id}"
    )
    
    if output_response.project:
        project = output_response.project
        # if project.current_iteration:
        #     iterations_row['description'] = project.current_iteration.description

        for name in project.representations:
            representation = project.representations[name]
            rep_dict = {
                "name": name,
                "type": representation.type,
                "text": representation.text,
                "project_id": pid,
                "is_pwr_viewable": representation.is_pwr_viewable,
                "is_user_viewable": True,
                "is_editable": representation.is_editable,
                "sort_order": representation.sort_order,
            }
            crud.create_representation(db, rep_dict)
    
    if output_response.type == "output" or output_response.type == "debug":
        crud.create_output_message(
            db,
            {
                "type": output_response.type,
                "sender": "bot",
                "session_id": output_response.session_id,
                "message": output_response.message,
                "project_id": pid,
            },
        )
    if not webhook:
        await outputChatManager.send_message_for_project_id(text, pid)
    else:
        requests.post(webhook, data=text)
    end = time.time()
    logger.info(
        f"#3E - main.py - Done Output Webhook {end - start}seconds; PwR-RID={output_response.correlation_id}"
    )

    return {"message": "ok"}

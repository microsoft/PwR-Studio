from sqlalchemy import and_, func
from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from . import models, schemas

# import models, schemas


def get_user(db: Session, oid: int):
    return db.query(models.User).filter(models.User.oid == oid).first()


def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()


def get_project(db: Session, project_id: int):
    return (
        db.query(models.Project)
        .filter(models.Project.id == project_id)
        .options(joinedload(models.Project.credentials))
        .first()
    )


def get_projects_for_user(db: Session, oid: str, skip: int = 0, limit: int = 100):
    project = (
        db.query(models.Project)
        .join(models.ProjectUser)
        .filter(models.Project.is_deleted == False)
        .filter(models.ProjectUser.oid == oid)
        .options(joinedload(models.Project.credentials))
        .order_by(models.Project.updated_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return project or []


def get_error_states(db: Session, pid: int):
    errorState = (
        db.query(models.ChatMessage)
        .filter(models.ChatMessage.project_id == pid)
        .filter(models.ChatMessage.type == "dsl_state")
        .order_by(models.ChatMessage.created_at.desc())
        .limit(1)
        .all()
    )
    return errorState or []


def get_plugins(db: Session, project_class: str):
    template = (
        db.query(models.Template)
        .filter(models.Template.project_class == project_class)
        .first()
    )

    if template:
        print(f"Template: {template.name}")
        for template_plugin in template.TemplatePlugins:
            plugin = template_plugin.plugin
            print(f"Plugin: {plugin.name}, Description: {plugin.description}")
    else:
        print(f"No template found for project class '{project_class}'")
    return template.TemplatePlugins if template else []


def get_project_user(db: Session, project_id: int, oid: str):
    return (
        db.query(models.ProjectUser)
        .filter(
            models.ProjectUser.project_id == project_id, models.ProjectUser.oid == oid
        )
        .first()
    )


def get_projects(db: Session, project_ids: list, skip: int = 0, limit: int = 100):
    return (
        db.query(models.Project)
        .filter(models.Project.id.in_(project_ids), models.Project.is_deleted == False)
        .order_by(models.Project.updated_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.User(**user.dict())
    db.add(db_user)
    db.commit()
    return db_user


def create_project_user(db: Session, project_user_dict):
    db_project_user = models.ProjectUser(**project_user_dict)
    db.add(db_project_user)
    db.commit()
    db.refresh(db_project_user)
    return db_project_user


def create_project(db: Session, project: schemas.ProjectCreate):
    db_project = models.Project(
        name=project.name,
        description=project.description,
        project_class=project.project_class,
        engine_url=project.engine_url,
        file_upload=project.file_upload,
        audio_upload=project.audio_upload,
        has_credentials=project.has_credentials,
    )

    for credential in project.credentials:
        db_credential = models.ProjectCredential(
            name=credential.name,
            description=credential.description,
            mandatory=credential.mandatory,
        )
        db_project.credentials.append(db_credential)

    for user in project.users:
        db_user = models.ProjectUser(oid=user.oid)
        db_project.users.append(db_user)

    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project


def import_project(db: Session, project: schemas.ProjectImport):
    db_project = models.Project(
        name=project.name,
        description=project.description,
        project_class=project.project_class,
        engine_url=project.engine_url,
        file_upload=project.file_upload,
        audio_upload=project.audio_upload,
        has_credentials=project.has_credentials,
    )

    for credential in project.credentials:
        db_credential = models.ProjectCredential(
            name=credential.name,
            description=credential.description,
            mandatory=credential.mandatory,
        )
        db_project.credentials.append(db_credential)

    for user in project.users:
        db_user = models.ProjectUser(oid=user.oid)
        db_project.users.append(db_user)

    for representation in project.representations:
        db_representation = models.Representation(
            name=representation.name,
            description=representation.description,
            sort_order=representation.sort_order,
            project_id=db_project.id,
        )
        db_project.representations.append(db_representation)

    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project


def create_representation(db: Session, representation_dict):
    db_representation = models.Representation(**representation_dict)
    db.add(db_representation)
    db.commit()
    db.refresh(db_representation)
    return db_representation


def create_export(db: Session, export_dict):
    db_export = models.Export(**export_dict)
    db.add(db_export)
    db.commit()
    db.refresh(db_export)
    return db_export


def create_representation(db: Session, representation_dict):
    db_representation = models.Representation(**representation_dict)
    db.add(db_representation)
    db.commit()
    db.refresh(db_representation)
    return db_representation


def get_representations(db: Session, project_id: int):
    latest_representations = (
        db.query(
            models.Representation.name,
            func.max(models.Representation.created_at).label("latest_created_at"),
            func.max(models.Representation.sort_order).label("max_sort_order"),
        )
        .filter(models.Representation.project_id == project_id)
        .group_by(models.Representation.name)
        .order_by(func.max(models.Representation.sort_order).asc())
        .subquery()
    )

    latest_versions = (
        db.query(models.Representation)
        .join(
            latest_representations,
            and_(
                models.Representation.name == latest_representations.c.name,
                models.Representation.created_at
                == latest_representations.c.latest_created_at,
            ),
        )
        .all()
    )

    return latest_versions


def update_project(db: Session, project_dict):
    db.query(models.Project).filter(models.Project.id == project_dict["id"]).update(
        {k: v for k, v in project_dict.items() if k != "id"}
    )
    db.commit()
    db_project = (
        db.query(models.Project).filter(models.Project.id == project_dict["id"]).first()
    )  # This may not be necessary
    # db.refresh(db_project)
    return db_project


# def update_project(db: Session, project: schemas.Project):
#     db_project = db.query(models.Project).filter(models.Project.id == project.id).first()
#     db_project.name = project.name
#     db_project.description = project.description
#     db_project.updated_at = datetime.utcnow()
#     db.commit()
#     db.refresh(db_project)
#     return db_project


def delete_project(db: Session, project_id: int):
    db_project = (
        db.query(models.Project).filter(models.Project.id == project_id).first()
    )
    db_project.is_deleted = True
    db.commit()
    db.refresh(db_project)
    return True


def get_template(db: Session, template_id: int):
    return (
        db.query(models.Template)
        .options(joinedload(models.Template.TemplateCredentials))
        .filter(models.Template.id == template_id)
        .first()
    )


def get_output_messages(db, project_id: int, session_id: str):
    return (
        db.query(models.OutputMessage)
        .filter(
            models.OutputMessage.project_id == project_id,
            models.OutputMessage.session_id == session_id,
        )
        .all()
    )


def get_templates(db: Session, skip: int = 0, limit: int = 100):
    return (
        db.query(models.Template)
        .order_by(models.Template.sort.asc())
        .options(joinedload(models.Template.tags))
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_template(db: Session, template: schemas.TemplateCreate):
    db_template = models.Template(**template.dict())
    db.add(db_template)
    db.commit()
    db.refresh(db_template)
    return db_template


def update_template(db: Session, template: schemas.Template):
    db_template = (
        db.query(models.Template).filter(models.Template.id == template.id).first()
    )
    db_template.name = template.name
    db_template.description = template.description
    db_template.representation = template.representation
    db_template.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_template)
    return db_template


def delete_template(db: Session, template_id: int):
    db_template = (
        db.query(models.Template).filter(models.Template.id == template_id).first()
    )
    db.delete(db_template)
    db.commit()
    return True


def get_chat_messages(db: Session, project_id: int, skip: int = 0, limit: int = 30):
    # ignoring limit for now
    return (
        db.query(models.ChatMessage)
        .filter(models.ChatMessage.project_id == project_id)
        .order_by(models.ChatMessage.created_at.desc())
        .offset(skip)
        .all()
    )


def create_output_message(db: Session, output_message):
    db_output_message = models.OutputMessage(**output_message)
    db.add(db_output_message)
    db.commit()
    db.refresh(db_output_message)
    return db_output_message


def create_chat_message(db: Session, chat_message):
    db_chat_message = models.ChatMessage(**chat_message)
    db.add(db_chat_message)
    db.commit()
    db.refresh(db_chat_message)
    return db_chat_message


def create_analytics_log(db: Session, analytics_log):
    db_analytics_log = models.AnalyticsLog(**analytics_log.dict())
    db.add(db_analytics_log)
    db.commit()
    db.refresh(db_analytics_log)
    return db_analytics_log

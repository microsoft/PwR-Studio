from sqlalchemy import (
    Boolean,
    Column,
    ForeignKey,
    Integer,
    String,
    DateTime,
    Enum,
    UniqueConstraint,
    JSON,
)
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base


class Tags(Base):
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)


class TemplateHasTags(Base):
    __tablename__ = "template_has_tags"
    id = Column(Integer, primary_key=True, index=True)
    template_id = Column(Integer, ForeignKey("templates.id"), index=True)
    tag_id = Column(Integer, ForeignKey("tags.id"), index=True)

    template = relationship("Template")
    tag = relationship("Tags")


class TemplateHasPlugins(Base):
    __tablename__ = "template_has_plugins"
    id = Column(Integer, primary_key=True, index=True)
    template_id = Column(Integer, ForeignKey("templates.id"), index=True)
    plugin_id = Column(Integer, ForeignKey("plugins.id"), index=True)

    template = relationship("Template")
    plugin = relationship("Plugins")


class Plugins(Base):
    __tablename__ = "plugins"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(
        String,
    )
    pypi_url = Column(
        String,
    )
    dsl = Column(
        String,
    )
    doc = Column(
        String,
    )
    icon = Column(
        String,
    )
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)


class Template(Base):
    __tablename__ = "templates"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(
        String,
    )
    project_class = Column(String, default="simple_bot")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)
    engine_url = Column(Boolean, default=False)
    file_upload = Column(Boolean, default=False)
    audio_upload = Column(Boolean, default=False)
    has_credentials = Column(Boolean, default=False)
    verified = Column(Boolean, default=False)
    sort = Column(Integer, default=10)

    tags = relationship("Tags", secondary="template_has_tags", overlaps="tags")

    TemplateCredentials = relationship("TemplateCredentials", back_populates="template")

    TemplatePlugins = relationship("TemplateHasPlugins", back_populates="template")


class TemplateCredentials(Base):
    __tablename__ = "template_has_credentials"
    id = Column(Integer, primary_key=True, index=True)
    template_id = Column(Integer, ForeignKey("templates.id"), index=True)
    name = Column(
        String,
    )
    description = Column(
        String,
    )
    mandatory = Column(Boolean, default=True)
    template = relationship("Template")
    created_at = Column(DateTime, default=datetime.utcnow)


class User(Base):
    __tablename__ = "users"
    oid = Column(String, primary_key=True, index=True)
    name = Column(
        String,
    )
    email = Column(
        String,
    )
    created_at = Column(DateTime, default=datetime.utcnow)


class ProjectUser(Base):
    __tablename__ = "users_has_projects"
    id = Column(Integer, primary_key=True, index=True)
    oid = Column(String, ForeignKey("users.oid"), index=True)
    project_id = Column(Integer, ForeignKey("projects.id"), index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    project = relationship("Project", back_populates="users")
    user = relationship("User")


class Project(Base):
    __tablename__ = "projects"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(
        String,
    )
    project_class = Column(
        String,
    )
    # This refers to a column in the same table, clarify this
    parent_id = Column(Integer, default=None)
    output_url = Column(
        String,
    )
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)
    is_template = Column(Boolean, default=False)
    is_deleted = Column(Boolean, default=False)
    engine_url = Column(Boolean, default=False)
    file_upload = Column(Boolean, default=False)
    audio_upload = Column(Boolean, default=False)
    has_credentials = Column(Boolean, default=False)

    credentials = relationship("ProjectCredential", back_populates="project")
    users = relationship("ProjectUser", back_populates="project")
    representations = relationship("Representation", back_populates="project")


class ProjectCredential(Base):
    __tablename__ = "project_has_credentials"
    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"), index=True)
    name = Column(
        String,
    )
    description = Column(
        String,
    )
    mandatory = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    project = relationship("Project", back_populates="credentials")


class Representation(Base):
    __tablename__ = "representation"

    # Representation Table requires a primary_key
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    type = Column(
        String,
    )
    text = Column(
        String,
    )
    project_id = Column(Integer, ForeignKey("projects.id"), index=True)
    is_editable = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)
    is_pwr_viewable = Column(Boolean, default=True)
    is_user_viewable = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    project = relationship("Project")


class ChatMessage(Base):
    __tablename__ = "dev_chat_messages"
    id = Column(Integer, primary_key=True, index=True)
    # id = Column(Integer, index=True) ## auto-incrementing counter
    session_id = Column(
        String,
    )
    project_id = Column(Integer, ForeignKey("projects.id"), index=True)
    sender_id = Column(
        String,
    )
    sender = Column(
        Enum("user", "bot", name="chat_user_type"),
    )
    type = Column(
        Enum(
            "instruction",
            "feedback",
            "thought",
            "output",
            "start",
            "dsl_state",
            "end",
            "error",
            "representation_edit",
            "files",
            name="chat_message_type",
        ),
    )
    message = Column(
        String,
    )
    created_at = Column(DateTime, default=datetime.utcnow)
    special_link = Column(
        String,
    )
    pbyc_comments = Column(
        String,
    )

    project = relationship("Project")


class OutputMessage(Base):
    __tablename__ = "output_chat_messages"
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(
        String,
    )
    sender_id = Column(
        String,
    )
    project_id = Column(Integer, ForeignKey("projects.id"), index=True)
    sender = Column(
        Enum("user", "bot", name="output_user_type"),
    )
    type = Column(
        Enum(
            "instruction",
            "feedback",
            "thought",
            "output",
            "callback",
            "debug",
            "start",
            "end",
            "error",
            name="output_message_type",
        ),
    )
    message = Column(
        String,
    )
    created_at = Column(DateTime, default=datetime.utcnow)
    special_link = Column(
        String,
    )
    pbyc_comments = Column(
        String,
    )

    project = relationship("Project")


class Export(Base):
    __tablename__ = "exports"

    # export_id = Column(Integer, primary_key=True, index=True)
    # auto-incrementing counter
    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"), index=True)
    sandbox_responsecode = Column(
        Integer,
    )
    created_at = Column(DateTime, default=datetime.utcnow)

    project = relationship("Project")

    # __table_args__ = (
    #     UniqueConstraint('iteration_id', 'project_id', name='_iteration_id_project_id_uc'),
    # )


class AnalyticsLog(Base):
    __tablename__ = "analytics_logs"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"), index=True)
    user_id = Column(String, ForeignKey("users.oid"), index=True)
    representation_name = Column(
        String,
    )
    data = Column(
        JSON,
    )
    timestamp = Column(DateTime, default=datetime.utcnow)

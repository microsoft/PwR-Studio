from pydantic import BaseModel
from typing import Optional, Union, Dict, Any, List
from datetime import datetime


class ProjectCredentialBase(BaseModel):
    name: str
    description: Union[str, None] = None


class ProjectCredential(ProjectCredentialBase):
    id: int
    project_id: int

    class Config:
        from_attributes = True


class ProjectCredentialCreate(BaseModel):
    name: str
    description: Union[str, None] = None
    mandatory: bool = True


class ProjectCredential(BaseModel):
    id: int
    name: str
    description: Union[str, None] = None
    project_id: int


class ProjectUserCreate(BaseModel):
    oid: str


class ProjectUser(BaseModel):
    id: int
    oid: str
    project_id: int


class ProjectBase(BaseModel):
    name: str
    description: Union[str, None] = None
    project_class: str
    engine_url: bool = False
    file_upload: bool = False
    audio_upload: bool = False
    has_credentials: bool = False
    credentials: Any = list()
    users: Any = list()

    class Config:
        from_attributes = True


class UserBase(BaseModel):
    oid: str
    name: str
    email: str


class UserCreate(UserBase):
    pass


class ProjectCreate(ProjectBase):
    pass
    # template_id: int #Template


class Project(ProjectBase):
    id: int
    created_at: datetime
    updated_at: datetime
    name: str
    description: str
    parent_id: Union[int, None] = None
    export_url: Union[str, None] = None
    is_template: bool
    engine_url: bool = False
    file_upload: bool = False
    audio_upload: bool = False
    has_credentials: bool = False
    # TODO: typecast correctly
    credentials: Any = []
    users: List[ProjectUser]

    class Config:
        from_attributes = True


class User(BaseModel):
    id: int
    project_id: int
    role: str
    last_login: datetime

    class Config:
        from_attributes = True


class RepresentationBase(BaseModel):
    name: str
    text: str


class RepresentationCreate(RepresentationBase):
    pass


class Representation(RepresentationBase):
    id: int
    project_id: int
    name: str
    type: str
    is_pwr_viewable: bool
    is_user_viewable: bool

    class Config:
        from_attributes = True


class ProjectImport(ProjectBase):
    representations: List[Representation]


class TemplateBase(BaseModel):
    name: str
    description: Union[str, None] = None
    project_class: str
    verified: bool = False
    tags: Any = list()


class TemplateCreate(TemplateBase):
    pass


class Template(TemplateBase):
    id: int
    updated_at: datetime

    class Config:
        from_attributes = True


class ChatMessageBase(BaseModel):
    type: str
    message: str
    session_id: str = None
    webhook: str = None


class ChatMessageWithCredentials(ChatMessageBase):
    credentials: Dict[str, str] = None
    engine_url: str = None
    response_url: str = None


class ChatMessageCreate(ChatMessageBase):
    pass


class ChatMessage(ChatMessageBase):
    id: int
    project_id: int
    sender: str
    special_link: Union[str, None] = None
    pbyc_comments: Union[str, None] = None
    created_at: datetime = datetime.now()

    class Config:
        from_attributes = True


class AnalyticsLogBase(BaseModel):
    name: str
    project_id: int
    user_id: str
    representation_name: str = None
    data: Dict[Any, Any] = None
    timestamp: datetime = datetime.now()


class TakeEditBase(BaseModel):
    webhook: str = None
    credentials: Dict[str, str] = None
    engine_url: str = None
    changed_representation: RepresentationCreate


class AnalyticsLogCreate(AnalyticsLogBase):
    pass

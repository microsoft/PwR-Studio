from typing import Dict, List, Optional
from pydantic import BaseModel, validator


class Representation(BaseModel):
    name: str
    text: str
    type: str
    is_pbyc_viewable: bool = True
    is_user_viewable: bool = True
    is_editable: bool = True
    sort_order: int = 1

    @validator("type")
    def validate_type(cls, v):
        if v not in ["md", "json", "image"]:
            raise ValueError("type must be either md, image, or json")
        return v


class Project(BaseModel):
    id: int
    name: str
    representations: Dict[str, Representation] = {}


class Response(BaseModel):
    type: str
    message: str
    project: Optional[Project] = None
    correlation_id: Optional[str] = None
    session_id: Optional[str] = None

    @validator("type")
    def validate_type(cls, v):
        valid_list = [
            "start",
            "end",
            "error",
            "thought",
            "debug",
            "output",
            "instruction",
            "feedback",
            "callback",
            "dsl_state",
        ]
        if v not in valid_list:
            raise ValueError(f'type must be one of {",".join(valid_list)}')
        return v


class ChatMessage(BaseModel):
    type: str
    message: str

    @validator("type")
    def validate_type(cls, v):
        if v not in ["user", "bot"]:
            raise ValueError(f"type must be either user or bot; not {v}")
        return v


class ChangedRepresentation(BaseModel):
    name: str
    text: str


class File(BaseModel):
    url: str
    name: str
    type: str


class Action(BaseModel):
    """
    This represents the data exchanged between the PbyC Studio and the PbyC Engine. It captures the current state of the project and the action that should be taken.
    """

    action: str
    engine_name: str
    utterance: Optional[str] = None
    project: Project
    changed_representation: Optional[ChangedRepresentation] = None
    chat_history: Optional[List[ChatMessage]] = None
    session_id: Optional[str]
    credentials: Optional[Dict[str, str]]
    correlation_id: Optional[str]
    engine_url: Optional[str]
    response_url: Optional[str]
    files: Optional[List[File]] = None

    @validator("action")
    def validate_action(cls, v):
        valid = [
            "initialize",
            "utterance",
            "representation_edit",
            "output",
            "export",
            "import",
        ]
        if v not in valid:
            raise ValueError(f'action must be one of {",".join(valid)}; not {v}')
        return v

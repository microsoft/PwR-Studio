from . import crud
import lib.pwr_studio.types as pwr_schema
import logging
from confluent_kafka import Producer, Consumer, KafkaException
import socket, os, logging


def generate_q_message(db, action, **kwargs):

    pid = kwargs.get("project_id") or kwargs.get("pid")
    changed_representation = kwargs.get("changed_representation") or None
    session_id = kwargs.get("session_id") or None
    project_data = kwargs.get("project") or None
    project = crud.get_project(db, project_id=pid)
    correlation_id = kwargs.get("correlation_id") or None
    credentials = kwargs.get("credentials") or None
    engine_url = kwargs.get("engine_url") or None
    response_url = kwargs.get("response_url") or None
    representations = crud.get_representations(db, project_id=pid)
    chat_messages = []
    if action == "output":
        chat_messages = crud.get_output_messages(
            db, project_id=pid, session_id=session_id
        )
    else:
        chat_messages = crud.get_chat_messages(db, project_id=pid)

    # TODO - move this into the DB query
    chat_history = [
        pwr_schema.ChatMessage(type=chat.sender, message=chat.message)
        for chat in chat_messages
        if chat.type in ["instruction", "feedback", "output"]
    ]

    project_data = pwr_schema.Project(
        id=project.id,
        name=project.name,
        representations={
            r.name: pwr_schema.Representation(
                name=r.name,
                text=r.text,
                is_pwr_viewable=r.is_pwr_viewable,
                is_user_viewable=r.is_user_viewable,
                is_editable=r.is_editable,
                sort_order=r.sort_order,
                type=r.type,
            )
            for r in representations
        },
    )

    q_message = pwr_schema.Action(
        action=action,
        correlation_id=correlation_id,
        engine_name=project.project_class,
        chat_history=chat_history,
        credentials=credentials,
        session_id=session_id,
        project=project_data,
        changed_representation=changed_representation,
        engine_url=engine_url,
        response_url=response_url,
    )

    if kwargs.get("utterance"):
        q_message.utterance = kwargs.get("utterance")

    if kwargs.get("files"):
        q_message.files = kwargs.get("files")

    if kwargs.get("changed_representations"):
        q_message.project.changed_representations = kwargs.get(
            "changed_representations"
        )

    return q_message.dict()

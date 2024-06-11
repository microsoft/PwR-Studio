from abc import ABC, abstractmethod
from collections.abc import Sequence
from typing import Dict, List, Callable, Awaitable
from pwr_studio.representations import PwRStudioRepresentation
from pwr_studio.types import ChangedRepresentation, Project, Response, ChatMessage, File
import traceback


class PwRStudioEngine(ABC):
    """
    This is the base class for all engines. It receives a project state from the studio and transforms it based on the user's input or action.

    Inherit from this class to create a new engine. You must implement the following methods:
    1. _get_representations
    2. _process_utterance
    3. _process_representation_edit
    4. _get_output
    5. _process_import
    6. _process_attachment

    """

    _project: Project
    _progress: Callable[[Response], Awaitable[None]]

    _credentials: Dict[str, str] = {}
    _correlation_id: str = None

    def __init__(
        self,
        project: Project,
        progress: Callable[[Response], Awaitable[None]],
        **kwargs,
    ):
        self._project = project
        self._progress = progress

        if "credentials" in kwargs:
            assert isinstance(kwargs["credentials"], Dict)
            # TODO - run through all tools and validate the credentials
            self._credentials = kwargs["credentials"]
        else:
            self._credentials = {}

        if "correlation_id" in kwargs:
            assert isinstance(kwargs["correlation_id"], str)
            self._correlation_id = kwargs["correlation_id"]

        if len(self._project.representations.keys()) == 0:
            self.initalize()

    @abstractmethod
    def _get_representations(self) -> List[PwRStudioRepresentation]:
        raise NotImplementedError()

    def initalize(self):
        pwrRepresentations = self._get_representations()
        for pwrRep in pwrRepresentations:
            name = pwrRep.get_name()
            data = pwrRep.get_data()
            self._project.representations[name] = data

    async def process_utterance(self, text: str, **kwargs):
        allowed_args = {"chat_history", "files"}
        argument_types = {}
        collection_argument_types = {"chat_history": ChatMessage, "files": File}

        self._validate_kwargs(
            kwargs, allowed_args, argument_types, collection_argument_types
        )

        await self._progress(Response(type="start", message=""))

        try:
            await self._process_utterance(text, **kwargs)
        except Exception as e:
            traceback.print_exc()
            error_message = f"An error occurred: {type(e).__name__} - {str(e)}"
            await self._progress(Response(type="error", message=error_message))

        await self._progress(Response(type="end", message=""))

    @abstractmethod
    async def _process_utterance(self, text: str, **kwargs):
        raise NotImplementedError()

    async def take_representation_edit(self, edit: ChangedRepresentation, **kwargs):

        allowed_args = {}
        argument_types = {}
        collection_argument_types = {}

        self._validate_kwargs(
            kwargs, allowed_args, argument_types, collection_argument_types
        )

        for arg in kwargs:
            if arg not in allowed_args:
                raise TypeError(f"Invalid keyword argument '{arg}'")

            if not isinstance(kwargs[arg], argument_types[arg]):
                raise TypeError(f"Invalid data type for argument '{arg}'")

        await self._progress(Response(type="start", message=""))

        try:
            await self._process_representation_edit(edit, **kwargs)
        except Exception as e:
            print(e)
            traceback.print_exc()
            error_message = f"An error occurred: {type(e).__name__} - {str(e)}"
            await self._progress(Response(type="error", message=error_message))

        await self._progress(Response(type="end", message=""))

    @abstractmethod
    async def _process_representation_edit(self, edit: ChangedRepresentation, **kwargs):
        raise NotImplementedError()

    async def get_output(self, message: str, **kwargs):

        allowed_args = {"chat_history", "files"}
        argument_types = {}
        collection_argument_types = {"chat_history": ChatMessage, "files": File}

        self._validate_kwargs(
            kwargs, allowed_args, argument_types, collection_argument_types
        )
        await self._progress(Response(type="start", message=""))

        try:
            await self._get_output(message, **kwargs)
        except Exception as e:
            print(e)
            traceback.print_exc()
            error_message = f"An error occurred: {type(e).__name__} - {str(e)}"
            await self._progress(Response(type="error", message=error_message))

        await self._progress(Response(type="end", message=""))

    @abstractmethod
    async def _get_output(self, message: str, **kwargs):
        raise NotImplementedError()

    async def process_import(self, **kwargs):

        allowed_args = {}
        argument_types = {}
        collection_argument_types = {}

        self._validate_kwargs(
            kwargs, allowed_args, argument_types, collection_argument_types
        )

        for arg in kwargs:
            if arg not in allowed_args:
                raise TypeError(f"Invalid keyword argument '{arg}'")

            if not isinstance(kwargs[arg], argument_types[arg]):
                raise TypeError(f"Invalid data type for argument '{arg}'")

        await self._progress(Response(type="start", message=""))

        try:
            await self._process_import(**kwargs)
        except Exception as e:
            print(e)
            traceback.print_exc()
            error_message = f"An error occurred: {type(e).__name__} - {str(e)}"
            await self._progress(Response(type="error", message=error_message))

        await self._progress(Response(type="end", message=""))

    @abstractmethod
    async def _process_import(self, **kwargs):
        raise NotImplementedError()
    
    async def process_attachment(self, **kwargs):
        try:
            await self._process_attachment(**kwargs)
        except Exception as e:
            print(e)
            traceback.print_exc()
            error_message = f"An error occurred: {type(e).__name__} - {str(e)}"
            await self._progress(Response(type="error", message=error_message))

        await self._progress(Response(type="end", message=""))
    
    @abstractmethod
    async def _process_attachment(self, **kwargs):
        raise NotImplementedError()

    def _validate_kwargs(
        self, kwargs, allowed_args, argument_types, collection_argument_types
    ):
        for arg in kwargs:
            if arg not in allowed_args:
                raise TypeError(f"Invalid keyword argument '{arg}'")

            valid_data_type = False

            if arg in collection_argument_types:
                if kwargs[arg] is None:
                    valid_data_type = True
                elif isinstance(kwargs[arg], Sequence) and all(
                    isinstance(item, collection_argument_types[arg])
                    for item in kwargs[arg]
                ):
                    valid_data_type = True
            elif arg in argument_types:
                if isinstance(kwargs[arg], argument_types[arg]):
                    valid_data_type = True

            if not valid_data_type:
                raise TypeError(f"Invalid data type for argument '{arg}'")

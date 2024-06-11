from abc import ABC, abstractmethod
from pwr_studio.types import Representation


class PwRStudioRepresentation(ABC):
    """
    This is the base class for all representations. It captures the current intermediate representation of the engine.

    Inherit from this class to create a new representation. You must implement the following methods:
    1. _get_inital_values
    """

    _data: Representation

    def __init__(self):
        self._data = self._get_initial_values()

    @abstractmethod
    def _get_initial_values(self) -> Representation:
        raise NotImplementedError

    def get_data(self) -> Representation:
        return self._data

    def get_name(self):
        return self._data.name


exports = [
    PwRStudioRepresentation
]

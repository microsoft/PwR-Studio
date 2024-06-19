---
layout: default
title: How to write your own Engine
---

An Engine converts the user's utternace into DSL and then other downstream artifacts like Natural Language Representation (Text, Visual), Code etc.

The Engine makes PwR Studio domain specific.

## Basics

We need to implement the `PwRStudioEngine` class:

```python

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
```

## Thinking the Representations

Representations help the non-developer user of the Studio get a better understanding of the program under development. Surface important information e.g. messages shown to the end user.

```python
class Representation(BaseModel):
    name: str
    text: str
    type: str
```

## Validation & Feedback

Checking for common design errors will tremendously help the user of the Studio. For example:
1. Dead or missing states
2. Handling all edge cases of Plugins

## Improving User Experience

The process for converting NL utterance to DSL and other artifacts is slow. You can help the user with multiple `progress` steps.
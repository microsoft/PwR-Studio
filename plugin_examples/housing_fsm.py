from typing import Any, Dict, Type, Optional
from jb_manager_bot import AbstractFSM
from jb_manager_bot.abstract_fsm import (
    Status,
    MessageType,
    FSMOutput,
    FSMIntent,
    Message,
    TextMessage,
)
from jb_manager_bot.abstract_fsm import Variables
from payment_plugin import PaymentPlugin


class HousingFSMVariables(Variables):
    token_payment_reference_id: Optional[str] = None
    full_payment_reference_id: Optional[str] = None


class HousingFSM(AbstractFSM):
    """
    This is the main FSM class for the Bandhu project.
    """

    states = [
        "zero",
        "select_language",
        "token_payment",
        "get_full_payment",
        "show_confirmation",
        "end",
    ]
    transitions = [
        {"source": "zero", "dest": "select_language", "trigger": "next"},
        {
            "source": "select_language",
            "dest": "token_payment",
            "trigger": "next",
        },
        {
            "source": "token_payment",
            "dest": "get_full_payment",
            "trigger": "next",
        },
        {
            "source": "get_full_payment",
            "dest": "show_confirmation",
            "trigger": "next",
        },
        {
            "source": "show_confirmation",
            "dest": "end",
            "trigger": "next",
        },
    ]
    conditions = set()
    output_variables = set()
    variable_names = HousingFSMVariables

    def __init__(self, send_message: callable, credentials: Dict[str, Any] = None):

        if credentials is None:
            credentials = {}

        self.credentials = {}

        self.plugins: Dict[str, AbstractFSM] = {
            "payment": PaymentPlugin(
                send_message=send_message,
                credentials={"RAZORPAY_API_KEY": credentials.get("RAZORPAY_API_KEY")},
            ),
        }

        self.variables = self.variable_names()

        super().__init__(send_message=send_message)

    def on_enter_select_language(self):
        self.status = Status.WAIT_FOR_ME
        self.send_message(FSMOutput(intent=FSMIntent.LANGUAGE_CHANGE))
        self.status = Status.WAIT_FOR_USER_INPUT

    def on_enter_token_payment(self):
        self.status = Status.WAIT_FOR_ME

        message_head = (
            "We'll make this easy for you:\n"
            "\n1) Pay a token amount of Rs. 600 to guarantee a match for you, whether or not you finalise this property"
        )
        self.send_message(
            FSMOutput(
                intent=FSMIntent.SEND_MESSAGE,
                message=Message(
                    message_type=MessageType.TEXT, text=TextMessage(body=message_head)
                ),
            )
        )
        amount = 600
        if (
            plugin_output := self.run_plugin("payment", amount=amount)
        ) == self.RUN_TOKEN:
            return
        payment_refernce_id = plugin_output["reference_id"]
        setattr(self.variables, "token_payment_reference_id", payment_refernce_id)
        self.status = Status.MOVE_FORWARD

    def on_enter_get_full_payment(self):
        self.status = Status.WAIT_FOR_ME
        amount = 20000
        if (
            plugin_output := self.run_plugin("payment", amount=amount)
        ) == self.RUN_TOKEN:
            return
        payment_refernce_id = plugin_output["reference_id"]
        setattr(self.variables, "full_payment_reference_id", payment_refernce_id)
        self.status = Status.MOVE_FORWARD
    
    def on_enter_show_confirmation(self):
        self.status = Status.WAIT_FOR_ME
        message_head = (
            "Thank you for your payment! We've received your token payment and full payment. "
            "We'll be in touch with you shortly to arrange a property visit and provide you with a verification code and the property location."
        )
        self.send_message(
            FSMOutput(
                intent=FSMIntent.SEND_MESSAGE,
                message=Message(
                    message_type=MessageType.TEXT, text=TextMessage(body=message_head)
                ),
            )
        )
        self.status = Status.MOVE_FORWARD


def test_machine(
    x: Type[AbstractFSM],
    send_message: callable,
    user_input: Optional[str] = None,
    callback_input: Optional[str] = None,
    credentials: Dict[str, Any] = None,
    **kwargs,
):
    """
    Method to test the FSM."""

    import json
    from pathlib import Path

    file = Path(x.__name__ + ".state")
    if file.exists():
        with open(file, "r") as f:
            state = json.load(f)
    else:
        state = None

    state = x.run_machine(
        send_message, user_input, callback_input, credentials, state, **kwargs
    )

    with open(file, "w") as f:
        json.dump(state, f, indent=4)


if __name__ == "__main__":
    import os

    os.remove("HousingFSM.state") if os.path.exists("HousingFSM.state") else None

    def cb(x: FSMOutput):
        print("\n\n")
        print(x.model_dump(exclude_none=True))
        print("\n\n")

    from collections import deque as Queue

    inputs = Queue([])
    credentials = {
        "RAZORPAY_API_KEY": "123",
    }
    while True:
        user_input, callback_input = (
            inputs.popleft()
            if inputs
            else (
                input("Please provide input: "),
                input("Please provide callback input: "),
            )
        )
        print(f"User Input: {user_input}")
        print(f"Callback Input: {callback_input}")
        user_input = callback_input if not user_input else user_input
        test_machine(
            HousingFSM,
            cb,
            user_input,
            callback_input=callback_input,
            credentials=credentials,
        )
import json
import uuid
from enum import Enum
from typing import Any, Dict, Optional
from jb_manager_bot import AbstractFSM, Variables
from jb_manager_bot.data_models import (
    FSMOutput,
    Status,
    FSMIntent,
    Message,
    MessageType,
    TextMessage,
)


def request_payment(amount: int, transaction_id: str) -> str:
    return f"https://bandhu.com/pay/{transaction_id}/{amount}"


class PaymentPluginReturnStatus(Enum):
    SUCCESS = "success"
    FAILED = "failed"


class PaymentPluginVariables(Variables):
    amount: Optional[int] = None
    reference_id: Optional[str] = None
    payment_status: Optional[str] = None


class PaymentPlugin(AbstractFSM):

    states = [
        "zero",
        "send_payment_request",
        "get_payment_status",
        "send_payment_success_confirmation",
        "send_payment_failed_confirmation",
        "end",
    ]
    transitions = [
        {
            "source": "get_payment_status",
            "dest": "send_payment_success_confirmation",
            "trigger": "next",
            "conditions": "is_payment_success",
        },
        {"source": "zero", "dest": "send_payment_request", "trigger": "next"},
        {
            "source": "send_payment_request",
            "dest": "get_payment_status",
            "trigger": "next",
        },
        {
            "source": "get_payment_status",
            "dest": "send_payment_failed_confirmation",
            "trigger": "next",
        },
        {
            "source": "send_payment_success_confirmation",
            "dest": "end",
            "trigger": "next",
        },
        {
            "source": "send_payment_failed_confirmation",
            "dest": "end",
            "trigger": "next",
        },
    ]
    conditions = {"is_payment_success"}
    output_variables = {"reference_id"}
    variable_names = PaymentPluginVariables
    return_status_values = PaymentPluginReturnStatus

    def __init__(self, send_message: callable, credentials: Dict[str, Any] = None):
        if credentials is None:
            credentials = {}

        self.credentials = {}
        self.credentials["RAZORPAY_API_KEY"] = credentials.get("RAZORPAY_API_KEY")
        if not self.credentials["RAZORPAY_API_KEY"]:
            raise ValueError("Missing credential: RAZORPAY_API_KEY")

        self.variables = self.variable_names()
        self.return_status_values = self.return_status_values.SUCCESS
        super().__init__(send_message)

    def on_enter_send_payment_request(self):
        self.status = Status.WAIT_FOR_ME
        amount = getattr(self.variables, "amount")
        ref_id = str(uuid.uuid4())
        setattr(self.variables, "reference_id", ref_id)
        security_deposit_link = request_payment(amount, ref_id)
        message_head = (
            "To confirm your booking, please pay your deposit using the link:\n"
            f"Security Deposit (held securely by Bandhu) Rs. {amount} {security_deposit_link}\n"
            "Please pay the amount within 24 hours"
        )
        self.send_message(
            FSMOutput(
                intent=FSMIntent.SEND_MESSAGE,
                message=Message(
                    message_type=MessageType.TEXT, text=TextMessage(body=message_head)
                ),
            )
        )
        self.status = Status.WAIT_FOR_CALLBACK

    def on_enter_get_payment_status(self):
        self.status = Status.WAIT_FOR_ME
        setattr(
            self.variables,
            "payment_status",
            json.loads(self.current_callback)["payment_status"],
        )
        self.status = Status.MOVE_FORWARD

    def on_enter_send_payment_success_confirmation(self):
        self.status = Status.WAIT_FOR_ME
        self.return_status = self.return_status_values.SUCCESS
        self.send_message(
            FSMOutput(
                intent=FSMIntent.SEND_MESSAGE,
                message=Message(
                    message_type=MessageType.TEXT,
                    text=TextMessage(body="Payment Received!"),
                ),
            )
        )
        self.status = Status.MOVE_FORWARD

    def on_enter_send_payment_failed_confirmation(self):
        self.status = Status.WAIT_FOR_ME
        self.return_status = self.return_status_values.FAILED
        self.send_message(
            FSMOutput(
                intent=FSMIntent.SEND_MESSAGE,
                message=Message(
                    message_type=MessageType.TEXT,
                    text=TextMessage(body="Payment Failed!"),
                ),
            )
        )
        self.status = Status.MOVE_FORWARD

    def is_payment_success(self):
        return getattr(self.variables, "payment_status") == "success"

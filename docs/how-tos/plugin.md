---
layout: default
title: How to write Plugins
---

Plugins in Studio consists of two files:
1. Natural Language description of the plugin interface (inputs, outputs, return codes)
2. Python library artifact that can be imported in the generated code.

When the app is installed it pulls plugin dependencies through extra-index--url to fetch packages from specific registries.

The following is an example of the Payment Plugin:

```yaml

name: payment_plugin
description: |
    The name of the plugin is payment. This plugin helps in collecting a payment from the user by generating a payment link.

    The inputs needed are:
        - mobile_number (type:str) : The mobile number of the user
        - name (type:str) : Name of the user
        - CLIENT_ID (type:str) : API secret key for the payment gateway
        - CLIENT_SECRET (type:str) : API secret key for the payment gateway
        - AMOUNT (type:int) : The amount to be collected from the user
        - REASON (type:str) : The reason for the payment

    The outputs provided are:
        - TXN_ID (type:str) : A unique transaction ID generated for the payment transaction
        
    Return codes are:
        - `SUCCESS`: Indicates that the payment was successfully collected.
        - `CANCELLED_BY_USER`: Indicates cancelled by the user.
        - `EXPIRED`: Indicates that the payment link has expired.
        - `SERVER_DOWNTIME`: Indicates that the server is down.
        - `SERVER_ERROR`: Indicates that there was an error in the server.
```
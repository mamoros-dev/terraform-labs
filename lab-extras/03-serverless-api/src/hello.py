"""Función Lambda del laboratorio 03.

API Gateway HTTP API (payload 2.0) invoca `handler` y espera un dict con
statusCode y body. No hace falta ningún framework: un GET /hello devuelve JSON.
"""

import json


def handler(event, context):
    """Punto de entrada de Lambda.

    event: datos de la petición HTTP que reenvía API Gateway
           (ruta, método, cabeceras, etc.). En este laboratorio no los usamos.
    context: metadatos de la invocación (request id, tiempo restante...).
    """
    body = {
        "message": "Hello from Terraform and AWS Lambda!",
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body),
    }

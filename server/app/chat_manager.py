from fastapi import WebSocket


class ChatConnectionManager:
    def __init__(self):
        self.active_connections: dict[WebSocket, int] = {}

    async def connect(self, project_id: int, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[websocket] = project_id

    def disconnect(self, websocket: WebSocket):
        del self.active_connections[websocket]

    async def send_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def send_message_for_project_id(self, message: str, project_id: int):
        for connection in self.active_connections:
            if self.active_connections[connection] == project_id:
                # if connection.client_state == 1:
                #     await connection.send_text(message)
                await connection.send_text(message)

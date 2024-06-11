from datetime import datetime, timedelta
from azure.storage.blob import BlobServiceClient
from azure.storage.blob import (
    ResourceTypes,
    AccountSasPermissions,
    generate_account_sas,
)


class BlobManager:

    def __init__(self, container_name, connection_str):
        self.service = BlobServiceClient.from_connection_string(connection_str)
        self.container_client = self.service.get_container_client(container_name)

    def upload_file(self, file_path, blob_name):
        with open(file_path, "rb") as data:
            self.container_client.get_blob_client(blob_name).upload_blob(data)

    def get_url(self, blob_name):
        # with SAS token
        blob_client = self.container_client.get_blob_client(blob_name)
        sas_token = generate_account_sas(
            self.service.account_name,
            account_key=self.service.credential.account_key,
            resource_types=ResourceTypes(object=True),
            permission=AccountSasPermissions(read=True),
            expiry=datetime.utcnow() + timedelta(hours=1),
        )
        return blob_client.url + "?" + sas_token

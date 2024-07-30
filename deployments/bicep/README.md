```bash
az deployment group create --name ExampleDeployment --resource-group jb-studio-test --parameters storage.bicepparam

az deployment group create --resource-group jb-studio-test --template-file ./main.bicep --parameters main.bicepparam
```
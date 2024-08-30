param location string
param containerName string
param subnetId string

param numberCpuCores string
param memory string

param imageRegistryLoginServer string
param imageName string
param imageUsername string
@secure()
param imagePassword string

param SERVER_HOST string
param dbConnectionString string

param AAD_APP_CLIENT_ID string
param AAD_APP_TENANT_ID string
param ISSUER string

param KAFKA_BROKER string
param KAFKA_PRODUCER_USERNAME string
@secure()
param KAFKA_PRODUCER_PASSWORD string


resource container 'Microsoft.ContainerInstance/containerGroups@2022-10-01-preview' = {
  location: location
  name: containerName
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: imageName
          resources: {
            requests: {
              cpu: int(numberCpuCores)
              memoryInGB: json(memory)
            }
          }
          environmentVariables: [
            {
              name: 'SERVER_HOST'
              value: SERVER_HOST
            }
            {
              name: 'DB_CONNECTION_STRING'
              value: dbConnectionString
            }
            {
              name: 'AAD_APP_CLIENT_ID'
              value: AAD_APP_CLIENT_ID
            }
            {
              name: 'AAD_APP_TENANT_ID'
              value: AAD_APP_TENANT_ID
            }
            {
              name: 'ISSUER'
              value: ISSUER
            }
            {
              name: 'KAFKA_BROKER'
              value: KAFKA_BROKER
            }
            {
              name: 'KAFKA_USE_SASL'
              value: 'true'
            }
            {
              name: 'KAFKA_ENGINE_TOPIC'
              value: 'pwr_engine'
            }
            {
              name: 'KAFKA_PRODUCER_USERNAME'
              value: KAFKA_PRODUCER_USERNAME
            }
            {
              name: 'KAFKA_PRODUCER_PASSWORD'
              secureValue: KAFKA_PRODUCER_PASSWORD
            }
          ]
          command: [
            'uvicorn'
            'app.main:app'
            '--workers'
            '1'
            '--host'
            '0.0.0.0'
            '--port'
            '80'
          ]
          ports: [{port: 80, protocol: 'TCP'}, {port: 3000, protocol: 'TCP'}]
        }
      }
    ]
    restartPolicy: 'OnFailure'
    osType: 'Linux'
    sku: 'Standard'
    imageRegistryCredentials: [
      {
        server: imageRegistryLoginServer
        username: imageUsername
        password: imagePassword
      }
    ]
    subnetIds: [
      {id: subnetId}
    ]
  }
  tags: {}
}


// output the private IP adress assigned to the container group from the subnet

output containerIP string = container.properties.ipAddress.ip

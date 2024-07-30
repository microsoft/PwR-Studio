param availabilityZones array
param location string
param containerName string
param imageName string

@allowed([
  'Linux'
  'Windows'
])
param osType string
param numberCpuCores string
param memory string

@allowed([
  'OnFailure'
  'Always'
  'Never'
])
param restartPolicy string

@allowed([
  'Standard'
  'Confidential'
])
param sku string
param imageRegistryLoginServer string
param imageUsername string

@secure()
param imagePassword string
param SERVER_HOST string
param dbConnectionString string
param AAD_APP_CLIENT_ID string
param AAD_APP_TENANT_ID string
param ISSUER string
param KAFKA_BROKER string
param KAFKA_USE_SASL string
param KAFKA_ENGINE_TOPIC string
param KAFKA_PRODUCER_USERNAME string

@secure()
param KAFKA_PRODUCER_PASSWORD string
param KAFKA_CONSUMER_USERNAME string

@secure()
param KAFKA_CONSUMER_PASSWORD string
param ipAddressType string
param ports array

resource container 'Microsoft.ContainerInstance/containerGroups@2022-10-01-preview' = {
  location: location
  name: containerName
  zones: availabilityZones
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
              value: KAFKA_USE_SASL
            }
            {
              name: 'KAFKA_ENGINE_TOPIC'
              value: KAFKA_ENGINE_TOPIC
            }
            {
              name: 'KAFKA_PRODUCER_USERNAME'
              value: KAFKA_PRODUCER_USERNAME
            }
            {
              name: 'KAFKA_PRODUCER_PASSWORD'
              secureValue: KAFKA_PRODUCER_PASSWORD
            }
            {
              name: 'KAFKA_CONSUMER_USERNAME'
              value: KAFKA_CONSUMER_USERNAME
            }
            {
              name: 'KAFKA_CONSUMER_PASSWORD'
              secureValue: KAFKA_CONSUMER_PASSWORD
            }
          ]
          ports: ports
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
        }
      }
    ]
    restartPolicy: restartPolicy
    osType: osType
    sku: sku
    imageRegistryCredentials: [
      {
        server: imageRegistryLoginServer
        username: imageUsername
        password: imagePassword
      }
    ]
    ipAddress: {
      type: ipAddressType
      ports: ports
    }
    subnetIds: [
      {
        // generate dynamically instead of hardcoding
        id: 'sss'
      }
    ]
  }
  tags: {}
}

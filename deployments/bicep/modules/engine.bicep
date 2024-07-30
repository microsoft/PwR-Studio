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
param KAFKA_BROKER string
param KAFKA_USE_SASL string
param KAFKA_CONSUMER_USERNAME string

@secure()
param KAFKA_CONSUMER_PASSWORD string
param KAFKA_ENGINE_TOPIC string

@secure()
param AZURE_OPENAI_API_KEY string
param AZURE_OPENAI_API_VERSION string
param AZURE_OPENAI_ENDPOINT string
param FAST_MODEL string
param SLOW_MODEL string
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
              name: 'KAFKA_BROKER'
              value: KAFKA_BROKER
            }
            {
              name: 'KAFKA_USE_SASL'
              value: KAFKA_USE_SASL
            }
            {
              name: 'KAFKA_CONSUMER_USERNAME'
              value: KAFKA_CONSUMER_USERNAME
            }
            {
              name: 'KAFKA_CONSUMER_PASSWORD'
              secureValue: KAFKA_CONSUMER_PASSWORD
            }
            {
              name: 'KAFKA_ENGINE_TOPIC'
              value: KAFKA_ENGINE_TOPIC
            }
            {
              name: 'AZURE_OPENAI_API_KEY'
              value: AZURE_OPENAI_API_KEY
            }
            {
              name: 'AZURE_OPENAI_API_VERSION'
              value: AZURE_OPENAI_API_VERSION
            }
            {
              name: 'AZURE_OPENAI_ENDPOINT'
              value: AZURE_OPENAI_ENDPOINT
            }
            {
              name: 'FAST_MODEL'
              value: FAST_MODEL
            }
            {
              name: 'SLOW_MODEL'
              value: SLOW_MODEL
            }
          ]
          ports: ports
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
  }
  tags: {}
}

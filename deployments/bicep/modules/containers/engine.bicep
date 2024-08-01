param location string
param containerName string
param subnetId string

param numberCpuCores string
param memory string

param imageRegistryLoginServer string
param imageUsername string
@secure()
param imagePassword string
param imageName string

param KAFKA_BROKER string
param KAFKA_CONSUMER_USERNAME string

@secure()
param KAFKA_CONSUMER_PASSWORD string

@secure()
param AZURE_OPENAI_API_KEY string
param AZURE_OPENAI_API_VERSION string
param AZURE_OPENAI_ENDPOINT string
param FAST_MODEL string = 'gpt-4-turbo'
param SLOW_MODEL string = 'gpt-4-turbo'

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
              name: 'KAFKA_BROKER'
              value: KAFKA_BROKER
            }
            {
              name: 'KAFKA_USE_SASL'
              value: 'true'
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
              value: 'pwr_engine'
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
          ports: [{port: 80, protocol: 'TCP'}]
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

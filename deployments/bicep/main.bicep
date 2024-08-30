// create bicep version of the stuff above

param resourceNamePrefix string
param location string
param postgresAdminUser string

@secure()
param postgresAdminPassword string

param postgresDatabaseName string
param cpu string = '0.5'
param memory string = '1Gi'

@secure()
param AZURE_OPENAI_API_KEY string
param AZURE_OPENAI_API_VERSION string
param AZURE_OPENAI_ENDPOINT string
param FAST_MODEL string = 'gpt-4-turbo'
param SLOW_MODEL string = 'gpt-4-turbo'

param pwrEngineImageName string
param pwrServerImageName string
@secure()
param imagePassword string
param imageRegistryLoginServer string
param imageUsername string

param AAD_APP_CLIENT_ID string
param AAD_APP_TENANT_ID string
param ISSUER string

param SERVER_HOST string

param keyVaultName string

@description('The secret url for the certificate in Azure Key Vault.')
@secure()
param keyVaultSecretId string

// deploy ./vnet.bicep

module vnet './modules/vnet.bicep' = {
  name: '${resourceNamePrefix}-vnet'
  params: {
    vnetName: '${resourceNamePrefix}-vnet'
  }
}

// deploy the files ./eventhub.bicep and postgres.bicep

module eventhub './modules/eventhub.bicep' = {
  name: '${resourceNamePrefix}-eventhub'
  params: {
    eventHubNamespace: '${resourceNamePrefix}-eventhub-namespace'
    location: location
  }
}

module postgres './modules/postgres.bicep' = {
  name: '${resourceNamePrefix}-postgres'
  params: {
    resourceNamePrefix: resourceNamePrefix
    location: location
    postgresAdminUser: postgresAdminUser
    postgresAdminPassword: postgresAdminPassword
    postgresDatabaseName: postgresDatabaseName
  }
}

module storage './modules/storage.bicep' = {
  name: '${resourceNamePrefix}-storage'
  params: {
    location: location
    resourceNamePrefix: resourceNamePrefix
  }
}


// create a public ip that will later be used for a load balancer

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${resourceNamePrefix}-public-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// deploy the files ./server.bicep and ./engine.bicep

module engine './modules/containers/engine.bicep' = {
  name: '${resourceNamePrefix}-engine'
  params: {
    location: location
    AZURE_OPENAI_API_KEY: AZURE_OPENAI_API_KEY
    AZURE_OPENAI_API_VERSION: AZURE_OPENAI_API_VERSION
    AZURE_OPENAI_ENDPOINT: AZURE_OPENAI_ENDPOINT
    FAST_MODEL: FAST_MODEL
    SLOW_MODEL: SLOW_MODEL
    
    containerName: '${resourceNamePrefix}-pwr-engine'
    imageName: pwrEngineImageName
    imagePassword: imagePassword
    imageRegistryLoginServer: imageRegistryLoginServer
    imageUsername: imageUsername
    KAFKA_BROKER: eventhub.outputs.kafkaBroker
    KAFKA_CONSUMER_PASSWORD: eventhub.outputs.kafkaConnectionPassword
    KAFKA_CONSUMER_USERNAME: eventhub.outputs.kafkaConnectionUsername
    memory: memory
    numberCpuCores: cpu
  }
}



module server './modules/containers/server.bicep' = {
  name: '${resourceNamePrefix}-server'
  params: {
    location: location

    containerName: '${resourceNamePrefix}-pwr-server'
    AAD_APP_CLIENT_ID: AAD_APP_CLIENT_ID
    AAD_APP_TENANT_ID: AAD_APP_TENANT_ID
    ISSUER: ISSUER
    // construct a full db string using the postgress params and the output server ip
    dbConnectionString: 'postgresql://${postgresAdminUser}:${postgresAdminPassword}@${postgres.outputs.postgresqlServerIP}:5432/${postgresDatabaseName}'
    SERVER_HOST: SERVER_HOST
    
    imageName: pwrServerImageName
    imagePassword: imagePassword
    imageRegistryLoginServer: imageRegistryLoginServer
    imageUsername: imageUsername
    KAFKA_BROKER: eventhub.outputs.kafkaBroker
    KAFKA_PRODUCER_PASSWORD: eventhub.outputs.kafkaConnectionPassword
    KAFKA_PRODUCER_USERNAME: eventhub.outputs.kafkaConnectionUsername
    memory: memory
    numberCpuCores: cpu
    subnetId: vnet.outputs.defaultSubnetId

  }
}


// create a load balancer that will be used to route traffic to the containers
// module gateway './modules/gateway.bicep' = {
//   name: '${resourceNamePrefix}-gateway'
//   params: {
//     resourceNamePrefix: resourceNamePrefix
//     location: location
//     subnetId: vnet.outputs.gatewaySubnetId
//     publicIpId: publicIp.id
//     backendIPAddress: server.outputs.containerIP
//     keyVaultName: keyVaultName
//     keyVaultSecretId: keyVaultSecretId
//   }
// }

output eventhubNamespace string = eventhub.outputs.kafkaBroker
output postgresqlServerName string = postgres.outputs.postgresqlServerIP


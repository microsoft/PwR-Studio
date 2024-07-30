// create bicep version of the stuff above

param resourceNamePrefix string
param location string
param availabilityZones array
param postgresAdminUser string

@secure()
param postgresAdminPassword string

param postgresDatabaseName string
param cpu string = '0.5'
param memory string = '1Gi'

var eventhubNamespace = '${resourceNamePrefix}-eventhub-namespace'
var publicIpName = '${resourceNamePrefix}-public-ip'
var containerAppEnvironmentName = '${resourceNamePrefix}-container-app-environment'
var containerAppName = '${resourceNamePrefix}-container-app'
var presetEnvironmentVariables = []


// deploy the files ./eventhub.bicep and postgres.bicep

module eventhub './modules/eventhub.bicep' = {
  name: '${resourceNamePrefix}-eventhub'
  params: {
    eventHubNamespace: eventhubNamespace
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


// deploy the files ./server.bicep and ./engine.bicep

module server './modules/server.bicep' = {
  name: '${resourceNamePrefix}-server'
  params: {
    location: location
    resourceNamePrefix: resourceNamePrefix
    postgresServerName: postgres.outputs.postgresqlServerIP
    eventhubNamespace: eventhub.outputs.kafkaBroker
  }
}

module engine './modules/engine.bicep' = {
  name: '${resourceNamePrefix}-engine'
  params: {
    location: location
    resourceNamePrefix: resourceNamePrefix
    postgresServerName: postgres.outputs.postgresqlServerIP
    eventhubNamespace: eventhub.outputs.kafkaBroker
  }
}

output eventhubNamespace string = eventhub.outputs.kafkaBroker
output postgresqlServerName string = postgres.outputs.postgresqlServerIP

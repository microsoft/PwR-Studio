@description('The name of the Event Hub namespace.')
param eventHubNamespace string

@description('The location for the resources.')
param location string

resource eventhubNamespace_resource 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespace
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
    isAutoInflateEnabled: true
    maximumThroughputUnits: 5
    kafkaEnabled: true
  }
}

resource eventhubNamespace_sendlisten 'Microsoft.EventHub/namespaces/authorizationrules@2024-01-01' = {
  parent: eventhubNamespace_resource
  name: 'sendlisten'
  properties: {
    rights: [
      'Send'
      'Listen'
    ]
  }
}

resource eventhubNamespace_pwr 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventhubNamespace_resource
  name: 'pwr_engine'
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 1
    }
    messageRetentionInDays: 1
    partitionCount: 3
    status: 'Active'
  }
}

resource eventhubNamespace_pwr_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-01-01' = {
  parent: eventhubNamespace_pwr
  name: '$Default'
  properties: {}
}

resource eventhubNamespace_pwr_cooler_group_id 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-01-01' = {
  parent: eventhubNamespace_pwr
  name: 'cooler_group_id'
  properties: {}
}

output kafkaConnectionUsername string = '$ConnectionString'
output kafkaConnectionPassword string = eventhubNamespace_sendlisten.listKeys().primaryConnectionString
output kafkaBroker string = '${eventHubNamespace}.servicebus.windows.net:9093'

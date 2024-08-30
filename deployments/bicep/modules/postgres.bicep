@description('The prefix used by all resources created by this template.')
param resourceNamePrefix string

@description('The location for the resources.')
param location string

@description('The administrator username for the PostgreSQL Flexible Server.')
param postgresAdminUser string

@description('The administrator password for the PostgreSQL Flexible Server.')
@secure()
param postgresAdminPassword string

@description('The name of the database to create in the PostgreSQL Flexible Server.')
param postgresDatabaseName string

var postgresqlServerName = '${resourceNamePrefix}-postgresql-server'

resource postgresqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: postgresqlServerName
  location: location
  properties: {
    replica: {
      role: 'Primary'
    }
    storage: {
      iops: 120
      tier: 'P4'
      storageSizeGB: 32
      autoGrow: 'Enabled'
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    dataEncryption: {
      type: 'SystemManaged'
    }
    authConfig: {
      activeDirectoryAuth: 'Disabled'
      passwordAuth: 'Enabled'
    }
    version: '16'
    administratorLogin: postgresAdminUser
    administratorLoginPassword: postgresAdminPassword
    availabilityZone: '1'
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    replicationRole: 'Primary'
  }
  sku: {
    name: 'Standard_D2ds_v4'
    tier: 'GeneralPurpose'
  }
}

resource postgresAllowAllAzureIPs 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-12-01-preview' = {
  parent: postgresqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgresqlServerName_postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-12-01-preview' = {
  parent: postgresqlServer
  name: postgresDatabaseName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

output postgresqlServerIP string = postgresqlServer.properties.fullyQualifiedDomainName

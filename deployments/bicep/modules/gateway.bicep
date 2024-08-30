@description('The resource ID of the subnet to which the Application Gateway should be connected.')
param subnetId string

@description('The private IP address of the backend server.')
param backendIPAddress string

@description('The secret url for the certificate in Azure Key Vault.')
@secure()
param keyVaultSecretId string

param location string = resourceGroup().location
param resourceNamePrefix string
param publicIpId string

param keyVaultName string

var managedIdentityName = '${resourceNamePrefix}-gateway-identity'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

// assign the identity to keyvault with name 
resource keyVaultAccess 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: managedIdentity.properties.principalId
        permissions: {
          keys: ['get', 'list']
          secrets: ['get', 'list']
        }
      }
    ]
  }
}


resource appGateway 'Microsoft.Network/applicationGateways@2020-06-01' = {
  name: '${resourceNamePrefix}-appGateway'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      // add the reference to the managed identity
      '${managedIdentity.id}': {}
    }
    
  }
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontendPortHttps'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: backendIPAddress
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpsListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              'appGateway',
              'appGatewayFrontendIP'
            )
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', 'appGateway', 'frontendPortHttps')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', 'appGateway', 'sslCertificate')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', 'appGateway', 'httpsListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'appGateway', 'backendPool')
          }
          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              'appGateway',
              'backendHttpSettings'
            )
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'sslCertificate'
        properties: {
          keyVaultSecretId: keyVaultSecretId
        }
      }
    ]
  }
}

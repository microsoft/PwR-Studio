@description('The name of the virtual network.')
param vnetName string


// create a virtual network with two subnets
resource pwrStudioVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: 'centralindia'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: [
            {
              name: 'Microsoft.ContainerInstance/containerGroups'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
      {
        name: 'gateway'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}


// output the subnets as well as network info

output defaultSubnetId string = pwrStudioVnet.properties.subnets[0].id
output gatewaySubnetId string = pwrStudioVnet.properties.subnets[1].id

// output network info too
output vnetId string = pwrStudioVnet.id

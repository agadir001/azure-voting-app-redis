@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

param roleAcrPull string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
param aksName string 
resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview'  existing = {
  name: aksName
}
//output aksPrincipalID string = aks.properties.identityProfile.kubeletidentity.objectId

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' =  {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}
resource assignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: 'AssignAcrPullToAks'
  scope: acrName
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: aks.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleAcrPull
  }
}

@description('Output the login server property for later use')
output loginServer string = acr.properties.loginServer

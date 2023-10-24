@description('The name of the Managed Cluster resource.')
param clusterName string = 'aks101cluster'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string 

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClOb5UpK1cFv+rJX5kbFJ30M8pRHqHV4EdCWOsbqaVOMTVwqnYavy5IHCnceVVMKh3exAWWwChzAHo0xbjAmOryNHEA+K/kFBWi5QwBKX70k5M5ozeT2zzuUPZrFt//HmE8GiMh/VlKDbmz2iRoDJLR5KMHZyPMdmuvCbKedGyLn70KOvV94UjyaQx2jSe+O0BCt+dVdUJEP9/XAqFb5vUHHWpCVyo4EMtRJS09devD2ntzh42u9Tw8cXq5dNDMxIcbhKVfXAlpR9ol9mTCJ/Zu75zmfFE/imy1/QSXGUj9kIJ0jiZ3UbnY0Ylut/HF5TUX87oUfLj6QnBpek+wh08qQuJaVy0CYfZa24bVQ8gAN4iEYwXcwuvPnHb+tv7t9B+Fzol8PeDfGbR5CsIkWQQ3kW2qnPKK+/EeUgY8KJkqqPG24Z6u0bzPBcSrikrwoimntV8d27YHs8X9+9poZAbpO9mDxQQHmmTXJXSYgWNMXEpDip09h2ASjzsVBV4qcE= azureuser@linuxvm'

//resource aksExist 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' existing = {
  //name: 'acrName'
//}if(aksExist.id == null)
resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' =  {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}
output controlPlaneFQDN string = aks.properties.fqdn

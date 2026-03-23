// ============================================================
// 疑似オンプレ VM（DC01, APP01, DB01）— 直接 Azure VM
// ============================================================

param location string
param tags object
param adminUsername string

@secure()
param adminPassword string

param subnetId string

// ============================================================
// DC01 — AD DS / DNS (Windows Server 2022)
// ============================================================

resource nicDc01 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: 'nic-DC01'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.10'
        }
      }
    ]
  }
}

resource vmDc01 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'DC01'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: 'DC01'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicDc01.id
        }
      ]
    }
  }
}

resource dc01Setup 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vmDc01
  name: 'setup-dc01'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File setup-dc01.ps1'
    }
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/ylearning86/Azure-Migration-Modernization-PoC-Handson/main/infra/scripts/setup-dc01.ps1'
      ]
    }
  }
}

// ============================================================
// APP01 — IIS + .NET Framework 4.8 (Windows Server 2019)
// ============================================================

resource nicApp01 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: 'nic-APP01'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.11'
        }
      }
    ]
  }
}

resource vmApp01 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'APP01'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: 'APP01'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicApp01.id
        }
      ]
    }
  }
}

resource app01Setup 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vmApp01
  name: 'setup-app01'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File setup-app01.ps1'
    }
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/ylearning86/Azure-Migration-Modernization-PoC-Handson/main/infra/scripts/setup-app01.ps1'
      ]
    }
  }
}

// ============================================================
// DB01 — SQL Server 2019 Developer (Windows Server 2019)
// ============================================================

resource nicDb01 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: 'nic-DB01'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.12'
        }
      }
    ]
  }
}

resource vmDb01 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'DB01'
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      computerName: 'DB01'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2019-ws2019'
        sku: 'sqldev-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: [
        {
          lun: 0
          createOption: 'Empty'
          diskSizeGB: 64
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicDb01.id
        }
      ]
    }
  }
}

resource sqlVmDb01 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-10-01' = {
  name: 'DB01'
  location: location
  tags: tags
  properties: {
    virtualMachineResourceId: vmDb01.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      sqlDataSettings: {
        luns: [0]
        defaultFilePath: 'F:\\SQLData'
      }
      sqlLogSettings: {
        luns: [0]
        defaultFilePath: 'F:\\SQLLog'
      }
    }
  }
}

resource db01Setup 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vmDb01
  name: 'setup-db01'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File setup-db01.ps1'
    }
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/ylearning86/Azure-Migration-Modernization-PoC-Handson/main/infra/scripts/setup-db01.ps1'
      ]
    }
  }
  dependsOn: [sqlVmDb01]
}

output dc01VmId string = vmDc01.id
output app01VmId string = vmApp01.id
output db01VmId string = vmDb01.id

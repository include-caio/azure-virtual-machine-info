function Get-AzureInfo {
    $Uri = "http://169.254.169.254/metadata/instance?api-version=2023-07-01";
    $VmInfo = Invoke-RestMethod -Uri $Uri -Headers @{ "metadata" = "true" };
    
    Write-Output "Resource Name: $($VmInfo.compute.name)";
    Write-Output "Computer Name: $($VmInfo.compute.osProfile.computerName)";
    Write-Output "Location: $($VmInfo.compute.location)";
    Write-Output "Resource Group: $($VmInfo.compute.resourceGroupName)";
    Write-Output "Subscription Id: $($VmInfo.compute.subscriptionId)";
    Write-Output "VM Size: $($VmInfo.compute.vmSize)";
    
    $InterfaceCount = $VmInfo.network.interface.Count;
    for ($i = 0; $i -lt $InterfaceCount; $i++) {
        $IPv4List = $VmInfo.network.interface[$i].ipv4.ipAddress;
        $IPv4Count = $IPv4List.Count;
        for ($j = 0; $j -lt $IPv4Count; $j++) {
            $PrivateIPv4 = $VmInfo.network.interface[$i].ipv4.ipAddress[$j].privateIpAddress;
            Write-Output "Private IPv4: $PrivateIPv4";
        }
    
        $IPv6List = $VmInfo.network.interface[$i].ipv6.ipAddress;
        $IPv6Count = $IPv6List.Count;
        for ($j=0; $j -lt $IPv6Count; $j++) {
            $PrivateIPv6 = $VmInfo.network.interface[$i].ipv6.ipAddress[$j].privateIpAddress;
            Write-Output "Private IPv6: $PrivateIPv6";
        }
    }
    
    $OsDiskName = $VmInfo.compute.storageProfile.osDisk.name;
    $OsDiskSize = $VmInfo.compute.storageProfile.osDisk.diskSizeGB;
    Write-Output "`nOS Disk:";
    Write-Output "Name: $OsDiskName | Size (GB): $OsDiskSize";
    
    $DataDisksCount = $VmInfo.compute.storageProfile.dataDisks.Count;
    if ($DataDisksCount -gt 0) {
        Write-Output "`nData Disks:";
        for ($i = 0; $i -lt $DataDisksCount; $i++) {
            $Lun = $VmInfo.compute.storageProfile.dataDisks[$i].lun;
            $DiskName = $VmInfo.compute.storageProfile.dataDisks[$i].name;
            $DiskSize = $VmInfo.compute.storageProfile.dataDisks[$i].diskSizeGB;
            $Device = (Get-WmiObject Win32_DiskDrive | Where-Object { $_.PNPDeviceID -like "*SCSI\DISK*" -and $_.SCSILogicalUnit -eq $Lun });
            $DeviceName = "$($Device.DeviceID) (Disk $($Device.Index))";
            Write-Output "LUN: $Lun | Name: $DiskName | Size (GB): $DiskSize | Device: $DeviceName";
        }
    }
}

Export-ModuleMember -Function Get-AzureInfo
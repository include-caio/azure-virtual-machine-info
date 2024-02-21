#!/bin/bash
function get_azure_info() {
    uri="http://169.254.169.254/metadata/instance?api-version=2023-07-01"
    vm_info=$(curl -sL -H "metadata:true" $uri)
    echo "Resource Name: $(echo $vm_info | jq -r .compute.name)"
    echo "Computer Name: $(echo $vm_info | jq -r .compute.osProfile.computerName)"
    echo "Location: $(echo $vm_info | jq -r .compute.location)"
    echo "Resource Group: $(echo $vm_info | jq -r .compute.resourceGroupName)"
    echo "Subscription Id: $(echo $vm_info | jq -r .compute.subscriptionId)"
    echo "VM Size: $(echo $vm_info | jq -r .compute.vmSize)"

    interface_count=$(echo $vm_info | jq -r ".network.interface | length")
    for ((i=0; i<$interface_count; i++)); do
        ipv4_list=$(jq -r .network.interface[$i].ipv4.ipAddress <<< $vm_info)
        ipv4_count=$(echo $ipv4_list | jq ". | length")
        for ((j=0; j<$ipv4_count; j++)); do
            private_ipv4=$(jq -r .network.interface[$i].ipv4.ipAddress[$j].privateIpAddress <<< $vm_info)
            echo -e "Private IPv4: $private_ipv4"
        done

        ipv6_list=$(jq -r .network.interface[$i].ipv6.ipAddress <<< $vm_info)
        ipv6_count=$(echo $ipv6_list | jq ". | length")
        for ((j=0; j<$ipv6_count; j++)); do
            private_ipv6=$(jq -r .network.interface[$i].ipv6.ipAddress[$j].privateIpAddress <<< $vm_info)
            echo -e "Private IPv6: $private_ipv6"
        done
    done

    os_disk_name=$(jq -r .compute.storageProfile.osDisk.name <<< $vm_info)
    os_disk_size=$(jq -r .compute.storageProfile.osDisk.diskSizeGB <<< $vm_info)
    echo -e "\nOS Disk:"
    echo -e "Name: $os_disk_name | Size (GB): $os_disk_size"
    
    data_disks_count=$(echo $vm_info | jq -r ".compute.storageProfile.dataDisks | length")
    if [[ $data_disks_count -gt 0 ]]; then
        echo -e "\nData Disks:"
        for ((i=0; i<$data_disks_count; i++)); do
            lun=$(jq -r .compute.storageProfile.dataDisks[$i].lun <<< $vm_info)
            disk_name=$(jq -r .compute.storageProfile.dataDisks[$i].name <<< $vm_info)
            disk_size=$(jq -r .compute.storageProfile.dataDisks[$i].diskSizeGB <<< $vm_info)
            device="/dev/"$(ls -l /dev/disk/azure/scsi1/ | grep "lun$lun " | awk "{ print \$11 }" | tr -cd "[:alnum:]")
            echo -e "LUN: $lun | Name: $disk_name | Size (GB): $disk_size | Device: $device"
        done
    fi
}
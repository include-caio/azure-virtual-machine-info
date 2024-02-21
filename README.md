## Scripts para obter informações do ambiente Azure em Máquinas Virtuais

O objetivo desses scripts é trazer informações do ambiente Azure (Resource Group, Subscription, Size, Discos etc) diretamente na máquina virtual

As funções utilizam o [Instance Metadata Service](https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service) do Azure para obter informações do recurso, sem necessidade de autenticação adicional, podendo ser utilizada por todos os usuários da máquina, auxiliando-os à obterem informações que só teriam acessando o portal do Azure ou fazendo a requisição no endpoint manualmente

## Utilização no Linux

Antes de utilizar, é necessário a instalação do [jq](https://jqlang.github.io/jq/download/)

A função pode ser adicionada no ```/etc/profile.d/``` para ficar disponível em todo o S.O

```bash
nano /etc/profile.d/get_azure_info.sh
sudo chmod +x /etc/profile.d/get_azure_info.sh
source /etc/profile
get_azure_info
```

Ou pode ser salva como um script comum em qualquer diretório, apenas adicionando a chamada para a função no final do arquivo

Depois de adicionada, basta chamar a função ```get_azure_info```

<img src="https://i.imgur.com/asaiGZ7.gif" width="550">

## Utilização no Windows

Nenhum pacote adicional é necessário, basta disponibilizar o módulo no S.O ou salvar o script como .ps1 e chamar ele ou a função ```Get-AzureInfo```

<img src="https://i.imgur.com/tTlx0Cu.gif" width="550">
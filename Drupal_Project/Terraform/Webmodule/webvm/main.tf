//Creating Public IPs for VMs
resource "azurerm_public_ip" "publicip" {
  count               = var.nodes
  name                = var.publicip_name[count.index]
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}
//Creating Subnets
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["${var.subnet_prefix}"]

}
//Creating Network Interfaces
resource "azurerm_network_interface" "network_interfaces" {
  count               = var.nodes
  name                = var.network_interfaces[count.index]
  location            = var.location
  resource_group_name = var.resource_group_name


  ip_configuration {
    name                          = var.publicip_name[count.index]
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
  depends_on = [
    azurerm_public_ip.publicip,
    azurerm_subnet.subnet
  ]
}
//Generating ssh_key 
resource "tls_private_key" "webkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

//Storing ssh_key in file
resource "local_file" "webkey" {
  filename= "webkey.pem"  
  content= tls_private_key.webkey.private_key_pem 
}

data "azurerm_client_config" "current" {}
//Creating Keyvault
resource "azurerm_key_vault" "keyvault" {
  name                        = "WebVMspasswords1799"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions  = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set", ]
    key_permissions     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", ]
    storage_permissions = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update", ]
  }
}
//Creating Secret to store ssh_key
resource "azurerm_key_vault_secret" "websecret" {
  name         = "websecretpassword"
  value        = tls_private_key.webkey.private_key_pem
  key_vault_id = azurerm_key_vault.keyvault.id
}

//Creating VM
resource "azurerm_virtual_machine" "vm" {
  count               = var.nodes
  name                = var.vm[count.index]
  location            = var.location
  resource_group_name = var.resource_group_name
  vm_size             = "Standard_B1s"


  network_interface_ids = [
    azurerm_network_interface.network_interfaces[count.index].id,
  ]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

    depends_on = [
    azurerm_public_ip.publicip,
    azurerm_network_interface.network_interfaces
  ]

  storage_os_disk {
    name              = var.disk[count.index]
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = var.vm[count.index]
    admin_username = "adminuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/adminuser/.ssh/authorized_keys"
      key_data = tls_private_key.webkey.public_key_openssh
    }
  }
//Establishing connection with VM
      connection {
      type = "ssh"
      user = "adminuser"
      host = azurerm_public_ip.publicip[count.index].ip_address
      private_key = azurerm_key_vault_secret.websecret.value
       } 
//Changing Permission of private key
    provisioner "local-exec" {
    command = "chmod 600 webkey.pem"
  }
//Copying file from local machine to VM   
  provisioner "file" {
    source      = "~/Desktop/Drupal_Project/web.sh"
    destination = "/home/adminuser/web.sh"
  }
  
//Executing commands in VMs
  provisioner "remote-exec" {
    inline = [
      "ls -a",
      "sudo chmod +x web.sh",
      "sudo sh web.sh",
    ]
  } 
 //Storing host information in local inventory
  provisioner "local-exec" {
    command = "echo ${azurerm_public_ip.publicip[count.index].ip_address} ansible_ssh_user=adminuser ansible_connection=ssh ansible_ssh_private_key_file=../Terraform/webkey.pem >> ../Ansible/inventory"
  }
}
//For executing ansible playbook
resource "null_resource" "ansibleexec"{

  provisioner "local-exec" {
	  command = "ansible-playbook -i ../Ansible/inventory --private-key=${azurerm_key_vault_secret.websecret.id} ../Ansible/execute.yml"
  }
    depends_on = [
      azurerm_virtual_machine.vm,
      ]

} 

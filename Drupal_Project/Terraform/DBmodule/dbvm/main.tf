//Creating Public IP for VM
resource "azurerm_public_ip" "publicip" {
  name                = var.publicip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}
//Creating Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = ["${var.subnet_prefix}"]

}
//Creating Network interface
resource "azurerm_network_interface" "network_interfaces" {
  name                = var.network_interfaces
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.publicip_name
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }

    depends_on = [
    azurerm_public_ip.publicip,
    azurerm_subnet.subnet
  ]
}
//Creating ssh key pair
resource "tls_private_key" "dbkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

//Creating local file for storing ssh_key
resource "local_file" "dbkey" {
  filename= "dbkey.pem"  
  content= tls_private_key.dbkey.private_key_pem 
}

data "azurerm_client_config" "current" {}
//Creating keyvault
resource "azurerm_key_vault" "keyvault" {
  name                        = "DBVMpasswords1799"
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
//Creating keyvault secret
resource "azurerm_key_vault_secret" "dbsecret" {
  name         = "dbsecretpassword"
  value        = tls_private_key.dbkey.private_key_pem
  key_vault_id = azurerm_key_vault.keyvault.id
}

//Creating Virtual Machine
resource "azurerm_virtual_machine" "vm" {
  name                = var.vm
  location            = var.location
  resource_group_name = var.resource_group_name
  vm_size             = "Standard_B1s"
  

  network_interface_ids = [
    azurerm_network_interface.network_interfaces.id,
  ]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "dbdisk"
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
    computer_name  = var.vm
    admin_username = "adminuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
     path     = "/home/adminuser/.ssh/authorized_keys"
     key_data = tls_private_key.dbkey.public_key_openssh
    }
    
  } //Establishing connection with vm
      connection {
      type = "ssh"
      user = "adminuser"
      host = azurerm_public_ip.publicip.ip_address
      private_key = azurerm_key_vault_secret.dbsecret.value
       } 
//Changing permission of private key
   provisioner "local-exec" {
    command = "chmod 600 dbkey.pem"
  }
 //Copying file from local machine to VM     
  provisioner "file" {
    source      = "~/Desktop/Drupal_Project/web.sh"
    destination = "/home/adminuser/web.sh"
  }
 
//Ececuting command in VM
  provisioner "remote-exec" {
    inline = [
      "ls -a",
      "sudo chmod +x web.sh",
      "sudo sh web.sh",
    ]
  }
}
//Creating local inventory file
resource "local_file" "localinventory" {
  filename = "../Ansible/inventory"
    content = <<EOT
[dbserver]
#ip_address_of_dbservers
${azurerm_public_ip.publicip.ip_address} ansible_user=adminuser ansible_connection=ssh ansible_ssh_private_key_file=../Terraform/dbkey.pem
[webserver] 
#ip_address_of_webservers 
EOT

    depends_on = [
      azurerm_virtual_machine.vm,
      ]
}
//For running playbook 
resource "null_resource" "ansibleexec"{

  provisioner "local-exec" {
	  command = "ansible-playbook -i ../Ansible/inventory --private-key=${azurerm_key_vault_secret.dbsecret.id} ../Ansible/execute.yml"
  }
    depends_on = [
      local_file.localinventory,
      ]

} 



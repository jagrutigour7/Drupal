output "public_ip_address" {
  value = (module.webvm.*.public_ip_address)
}

output "vm_name" {
    value = (module.webvm.*.vm_name)
}
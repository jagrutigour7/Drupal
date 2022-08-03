output "dbvm_public_ip_address" {
  value = concat(module.DBmodule.*.vm_name, module.DBmodule.*.public_ip_address)
}

output "webvm_public_ip_address" {
  value = concat(module.Webmodule.*.vm_name, module.Webmodule.*.public_ip_address)
}
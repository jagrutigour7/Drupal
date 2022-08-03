output "public_ip_address" {
  value = (module.dbvm.*.public_ip_address)
}

output "vm_name" {
    value = (module.dbvm.*.vm_name)
}
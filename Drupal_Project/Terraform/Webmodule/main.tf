
module "webnsg" {
  source   = "/home/einfochips/Desktop/Drupal_Project/Terraform/Webmodule/webnsg"
  location = var.location

}

module "webvm" {
  source   = "/home/einfochips/Desktop/Drupal_Project/Terraform/Webmodule/webvm"
  location = var.location
}

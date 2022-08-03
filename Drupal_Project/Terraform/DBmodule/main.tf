module "dbnsg" {
  source   = "/home/einfochips/Desktop/Drupal_Project/Terraform/DBmodule/dbnsg"
  location = var.location

}

module "dbvm" {
  source   = "/home/einfochips/Desktop/Drupal_Project/Terraform/DBmodule/dbvm"
  location = var.location
}

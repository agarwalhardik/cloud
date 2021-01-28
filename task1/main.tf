provider "google" {
  project     = "grand-signifier-282707"
  region      = "us-central1"
}

module "network" {
  source="./mynetwork"
}

module "firewall" {
  source="./FWrules"
  vpc_name = module.network.vpc_name
}

module "instances" {
  source="./instances"
  vpc_name = module.network.vpc_name
  private_subnet_name = module.network.private_subnet_name
  public_subnet_name = module.network.public_subnet_name
  /*WORDPRESS_DB_HOST = var.WORDPRESS_DB_HOST
  WORDPRESS_DB_USER = var.WORDPRESS_DB_USER
  WORDPRESS_DB_PASSWORD = var.WORDPRESS_DB_PASSWORD
  WORDPRESS_DB_NAME = var.WORDPRESS_DB_NAME
  MYSQL_ROOT_PASSWORD = var.MYSQL_ROOT_PASSWORD
  MYSQL_USER = var.MYSQL_USER
  MYSQL_PASSWORD = var.MYSQL_PASSWORD
  MYSQL_DATABASE = var.MYSQL_DATABASE*/
}

/*module "umig" {
  source="./umig"
}*/



/*module "http-load-balancer" {
  source  = "./lb"
  name = ""
  project = ""
  url_map = ""
}*/
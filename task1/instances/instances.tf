/*
variable "WORDPRESS_DB_HOST" {
}

variable "WORDPRESS_DB_USER" {
}

variable "WORDPRESS_DB_PASSOWRD" { 
}

variable "WORDPRESS_DB_NAME" {  
}

variable "MYSQL_ROOT_PASSWORD" { 
}

variable "MYSQL_USER" {  
}

variable "MYSQL_PASSWORD" { 
}

variable "MYSQL_DATABASE" {  
}*/

variable "vpc_name" {  
}
variable "private_subnet_name" {  
}
variable "public_subnet_name" {
}

/*resource "google_compute_address" "static1" {
  name = "ipv4-address1"
}

resource "google_compute_address" "static2" {
  name = "ipv4-address2"
}*/

resource "google_compute_instance" "instance1" {
    //depends_on = [ google_compute_address.static1 ]
  name         = "php1"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["wordpress"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20210119"
    }
  }

  network_interface {
    network = var.vpc_name
    subnetwork = var.public_subnet_name
    access_config {
      //nat_ip = google_compute_address.static1.address
    }
  }

  metadata_startup_script = "apt install apache2 php php-sql wget ; wget https://wordpress.org/latest.tar.gz ; tar -xvf latest.tar.gz ; cp -R wordpress /var/www/html/ ; chown -R www-data:www-data /var/www/html/wordpress/ ; chmod -R 755 /var/www/html/wordpress/ ; mkdir /var/www/html/wordpress/wp-content/uploads ; chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads/ ; systemctl start apache2"

  /*metadata = {
    WORDPRESS_DB_HOST = var.WORDPRESS_DB_HOST
    WORDPRESS_DB_USER = var.WORDPRESS_DB_USER
    WORDPRESS_DB_PASSWORD = var.WORDPRESS_DB_PASSOWRD
    WORDPRESS_DB_NAME = var.WORDPRESS_DB_NAME
  }*/
  desired_status = "RUNNING"

}

resource "google_compute_instance" "instance2" {
    //depends_on = [ google_compute_address.static2 ]
  name         = "php2"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["wordpress"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20210119"
    }
  }
  metadata_startup_script = "apt install apache2 php php-sql wget ; wget https://wordpress.org/latest.tar.gz ; tar -xvf latest.tar.gz ; cp -R wordpress /var/www/html/ ; chown -R www-data:www-data /var/www/html/wordpress/ ; chmod -R 755 /var/www/html/wordpress/ ; mkdir /var/www/html/wordpress/wp-content/uploads ; chown -R www-data:www-data /var/www/html/wordpress/wp-content/uploads/ ; systemctl start apache2"

  network_interface {
    network = var.vpc_name
    subnetwork = var.public_subnet_name
    access_config {
      //nat_ip = google_compute_address.static2.address
    }
  }

  /*metadata = {
    WORDPRESS_DB_HOST = var.WORDPRESS_DB_HOST
    WORDPRESS_DB_USER = var.WORDPRESS_DB_USER
    WORDPRESS_DB_PASSWORD = var.WORDPRESS_DB_PASSOWRD
    WORDPRESS_DB_NAME = var.WORDPRESS_DB_NAME
  }*/
  desired_status = "RUNNING"

}

resource "google_compute_instance" "db_instance1" {
    //depends_on = [ google_compute_subnetwork.private_subnet ]
  name         = "database"
  machine_type = "e2-medium"
  zone         = "us-central1-b"

  tags = ["db"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20210119"
    }
  }

  network_interface {
    network = var.vpc_name
    subnetwork = var.private_subnet_name

  }

  /*metadata = {
    MYSQL_ROOT_PASSWORD = var.MYSQL_ROOT_PASSWORD
    MYSQL_USER = var.MYSQL_USER
    MYSQL_PASSWORD = var.MYSQL_PASSWORD
    MYSQL_DATABASE = var.MYSQL_DATABASE
  }*/
  desired_status = "RUNNING"
}


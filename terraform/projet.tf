####---###### CREATATION OF SHARED RESSOURCES  #####---#####
 # Create a private network in cloud provider 
resource "ovh_cloud_project_network_private" "network_1918" {
  service_name = var.service_name
  name         = "network_1918"                        # Nom du réseau
  provider     = ovh.ovh                                  # Nom du fournisseur
  vlan_id      = var.vlan_id                              # Identifiant du vlan pour le vRrack
  regions = ["GRA11","SBG5"]
}
# Create a subnet in private network
resource "ovh_cloud_project_network_private_subnet" "subnet" {
    count = length(["GRA11","SBG5"])
    service_name = var.service_name
    region = ["GRA11","SBG5"][count.index]
    network_id   = ovh_cloud_project_network_private.network_1918.id
    start        = var.vlan_dhcp_start                          # Première IP du sous réseau
    end          = var.vlan_dhcp_end                            # Dernière IP du sous réseau
    network      = var.vlan_dhcp_network
    dhcp         = true                                         # Activation du DHCP
    provider     = ovh.ovh                                      # Nom du fournisseur
    no_gateway   = true                                         # Pas de gateway par defaut
}

#---------- Create BACKENDS in region GRA11 -------------#
# Create ssh keypair for region GRA
resource "openstack_compute_keypair_v2" "keypair_GRA" {
  provider   = openstack.ovh
  name       = "sshkey__eductive07_gra"
  public_key = file("~/.ssh/id_rsa.pub")
  region     = var.region_gra
}
resource "openstack_compute_instance_v2" "PROJET_final_GRA" {
#--- count is number of backends to be created
  count       = 3
  name        = "${var.instance_name_gra}_${count.index+1}"  # Nom concaténé
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = var.region_gra           # Nom de la régions

#>>>>> RESSOURCE <<<<< # Apply previously created ssh keypair for this region
  key_pair    = openstack_compute_keypair_v2.keypair_GRA.name  
#>>>>> RESSOURCE <<<<< #  Apply private IP then created private netw and subnet
  network {
    name      = "Ext-Net"
  }
  network {
    name = ovh_cloud_project_network_private.network_1918.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet]
}
#---------- Create FRONTEND in region GRA11  -------------#
resource "openstack_compute_instance_v2" "PROJET_final_GRA_Front" {
  name        = var.instance_name_gra_front  # Nom concaténé
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = var.region_gra           # Nom de la régions
#>>>>> RESSOURCE <<<<< # Apply previously created ssh keypair for this region
  key_pair    = openstack_compute_keypair_v2.keypair_GRA.name
#>>>>> RESSOURCE <<<<< #  Apply private IP then created private netw and subnet
  network {
    name      = "Ext-Net"
  }
  network {
   name = ovh_cloud_project_network_private.network_1918.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet]
}
#---------- Create BACKENDS in region SBG5 -------------#
## Create ssh keypair for region SBG
resource "openstack_compute_keypair_v2" "keypair_SBG" {
  provider   = openstack.ovh
  name       = "sshkey__eductive07_sbg"
  public_key = file("~/.ssh/id_rsa.pub")
  region     = var.region_sbg
}

# Création des instances chez SBG5
resource "openstack_compute_instance_v2" "PROJET_final_SBG" {
  count       = 3
  name        = "${var.instance_name_sbg}_${count.index+1}"  # Nom concaténé
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = var.region_sbg           # Nom de la régions

#>>>>> RESSOURCE <<<<< # Apply previously created ssh keypair for this region
  key_pair    = openstack_compute_keypair_v2.keypair_SBG.name
#>>>>> RESSOURCE <<<<< #  Apply private IP then created private netw and subnet
  network {   
    name      = "Ext-Net"   
  }
  network {
    name = ovh_cloud_project_network_private.network_1918.name
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet]
}

#---------- Create DATABASE based on CP services -------------#
#--- Created database based on ovh's mysql service
resource "ovh_cloud_project_database" "db_eductive07" {
  service_name = var.db_vars.service_name 
  description  = var.db_vars.description
  engine       = var.db_vars.engine
  version      = var.db_vars.version
  plan         = var.db_vars.plan
  flavor       = var.db_vars.flavor
  nodes {
    region = var.db_vars.region
  }
}
#--- Create database service's user
resource "ovh_cloud_project_database_user" "eductive07" {
  service_name = ovh_cloud_project_database.db_eductive07.service_name
  cluster_id   = ovh_cloud_project_database.db_eductive07.id
  engine       = "mysql"
  name         = "eductive07"
}

#--- Create a database inside Database service
resource "ovh_cloud_project_database_database" "db_wordpress" {
  service_name  = ovh_cloud_project_database.db_eductive07.service_name
  engine        = ovh_cloud_project_database.db_eductive07.engine
  cluster_id    = ovh_cloud_project_database.db_eductive07.id
  name          = "db_wordpress"
}
#--- Limit database connection to previously created instance's public ip - GRA Instances
resource "ovh_cloud_project_database_ip_restriction" "iprestriction_gra" {
  count        = length(openstack_compute_instance_v2.PROJET_final_GRA)
  service_name = ovh_cloud_project_database.db_eductive07.service_name
  engine       = ovh_cloud_project_database.db_eductive07.engine
  cluster_id   = ovh_cloud_project_database.db_eductive07.id
  ip           = "${openstack_compute_instance_v2.PROJET_final_GRA[count.index].access_ip_v4}/32"
}
#--- Limit database connection to previously created instance's public ip - SBG Instances
resource "ovh_cloud_project_database_ip_restriction" "iprestriction_sbg" {
  count        = length(openstack_compute_instance_v2.PROJET_final_SBG)
  service_name = ovh_cloud_project_database.db_eductive07.service_name
  engine       = ovh_cloud_project_database.db_eductive07.engine
  cluster_id   = ovh_cloud_project_database.db_eductive07.id
  ip           = "${openstack_compute_instance_v2.PROJET_final_SBG[count.index].access_ip_v4}/32"
}

##############  OUTPUT.TF IS MANDATORY  ####################
## sensitive values as db_username or db_user_password can be check using the following command in terminal : 
## export DB_USER=$(./terraform_bin output -raw db_username) ### or replace ./terraform_bin by 'terraform'
## echo $DB_USER
############################################################


####---###### ANSIBLE INVENTORY  #####---#####
# base on ./inventory.tmpl
# this file contains ansible inventory without vars or hosts
resource "local_file" "inventory" {
  filename = "../ansible/inventory.yml"

# Those loop scan previously created ressource to get defined variables such as IP or name
# Vars will be used in ./inventory.tmpl to build ansible's inventory.yml
# Some sensitive vars are gathered by output.tf and added to inventory.tmpl
  content = templatefile("inventory.tmpl",
    {
      nodes_backend_sbg = [for k, p in openstack_compute_instance_v2.PROJET_final_SBG: p.access_ip_v4],
      nodes_backend_gra = [for k, p in openstack_compute_instance_v2.PROJET_final_GRA: p.access_ip_v4],
      nodes_front_gra = openstack_compute_instance_v2.PROJET_final_GRA_Front.access_ip_v4,
      nodes_db_service = ovh_cloud_project_database.db_eductive07.endpoints.0.domain,
      nodes_db_username = ovh_cloud_project_database_user.eductive07.name,
      nodes_db_password = ovh_cloud_project_database_user.eductive07.password,
      nodes_db_wordpress = ovh_cloud_project_database_database.db_wordpress.name,
      nodes_db_port = ovh_cloud_project_database.db_eductive07.endpoints.0.port,
    }
  )
}

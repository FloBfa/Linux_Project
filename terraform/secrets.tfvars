# $var from openrc.sh
#----->  partie ovh à commenter
ovh = {
  endpoint           = "ovh-eu"
  application_key    = "$OVH_APPLICATION_KEY"
  application_secret = "$OVH_APPLICATION_SECRET"
  consumer_key       = "$OVH_CONSUMER_KEY"
}

product = {
  #test proj_id anciennement $OS_TENANT_ID
  project_id = "$OS_TENANT_ID"
  name       = "mysql_eductive07"
  region     = "GRA"
  plan       = "essential"
  flavor     = "db1-4"
  version    = "888"
}

access = {
  name = "eductive07"
  ip = "0.0.0.0/0"
}

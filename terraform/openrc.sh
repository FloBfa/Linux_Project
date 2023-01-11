#!/bin/bash

# To use an Openstack cloud you need to authenticate against keystone, which
# returns a **Token** and **Service Catalog**. The catalog contains the
# endpoint for all services the user/tenant has access to - including nova,
# glance, keystone, swift.
#
export OS_AUTH_URL=https://auth.cloud.ovh.net/v3
export OS_IDENTITY_API_VERSION=3

export OS_USER_DOMAIN_NAME=${OS_USER_DOMAIN_NAME:-"Default"}
export OS_PROJECT_DOMAIN_NAME=${OS_PROJECT_DOMAIN_NAME:-"Default"}


# With the addition of Keystone we have standardized on the term **tenant**
# as the entity that owns the resources.
export OS_TENANT_ID=9957f50cea694f13b26cc064d04b2e95
export OS_TENANT_NAME="2089539905429301"

# In addition to the owning entity (tenant), openstack stores the entity
# performing the action as the **user**.
export OS_USERNAME="user-EEDZUQcXdjPf"

# With Keystone you pass the keystone password.
export OS_PASSWORD="DHKjj27UZDvt6Pjx2gpCe7ZD2X322Hub"

# If your configuration has multiple regions, we set that information here.
export OS_REGION_NAME="GRA11"


export OVH_ENDPOINT="ovh-eu"
export OVH_APPLICATION_KEY="bJQ4YaOX26rqrg90"
export OVH_APPLICATION_SECRET="hJLKRf5aMGYdAwnbR5Lcq0FsQ2M7ShKZ"
export OVH_CONSUMER_KEY="456eef79d02ad580f5ae6d2aed1b61d2"
export OVH_VRACK="pn-1089024"  # Manually created
export OVH_PUBLIC_CLOUD=$OS_TENANT_ID
export OVH_PROJECT_ID=$OS_TENANT_ID
export OVH_CLOUD_PROJECT_SERVICE=$OS_TENANT_ID
export TF_ACC=1
export TF_VAR_region_name=$OS_REGION_NAME
export TF_VAR_service_name=$OS_TENANT_ID

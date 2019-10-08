# ------------------------------------------------------------------------------------
# This script creates the Cloud services that the tutorial application utilizes:
# - Cloud Object Storage https://cloud.ibm.com/catalog/services/cloud-object-storage
# Prerequisites:
#  (1) IBM Cloud CLI is installed and included in PATH
# ------------------------------------------------------------------------------------

# Cloud Object Storage instance name
# If you change the name you must also change the create_serverless_app.* scripts
COS_INSTANCE_NAME=cloud-object-storage-lite

# Service plan name
# Lite (free), or Standard
SERVICE_PLAN_NAME=lite

# Resource group
RESOURCE_GROUP=default

# Create a Cloud Object Storage service instance (Lite/free plan) in the default resource group
# For help with this command run "ibmcloud resource service-instance-create --help"
ibmcloud resource service-instance-create $COS_INSTANCE_NAME cloud-object-storage $SERVICE_PLAN_NAME global -g $RESOURCE_GROUP

# Create a service key with write access in this instance
# For help with this command run "ibmcloud resource service-key-create --help" 
ibmcloud resource service-key-create serverless-write-access Writer --instance-name $COS_INSTANCE_NAME

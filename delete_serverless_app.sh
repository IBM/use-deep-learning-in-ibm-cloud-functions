# ----------------------------------------------------------
# This script removes Cloud Functions entities from the 
# selected namespace that implement the tutorial application.
# Prerequisites:
#  (1) IBM Cloud CLI is installed and included in PATH
#  (2) IBM Cloud Functions plugin is installed
# ----------------------------------------------------------

# Cloud Functions namespace where the tutorial application entities were created
NAMESPACE_NAME=analyze_images

ibmcloud fn property set --namespace $NAMESPACE_NAME

# List entities in the current namespace
ibmcloud fn list

# Delete the rules
ibmcloud fn rule delete bucket_jpg_write_rule
ibmcloud fn rule delete bucket_png_write_rule
ibmcloud fn rule delete bucket_jpg_delete_rule
ibmcloud fn rule delete bucket_png_delete_rule

# Delete Cloud Object Storage triggers
ibmcloud fn trigger delete bucket_jpg_write_trigger
ibmcloud fn trigger delete bucket_png_write_trigger
ibmcloud fn trigger delete bucket_jpg_delete_trigger
ibmcloud fn trigger delete bucket_png_delete_trigger

# Delete actions
ibmcloud fn action delete manage_pictures/bucket_write_action
ibmcloud fn action delete manage_pictures/bucket_delete_action

# Delete package
ibmcloud fn package delete manage_pictures

# List entities in the current namespace
ibmcloud fn list

# delete namespace
ibmcloud fn namespace delete $NAMESPACE_NAME

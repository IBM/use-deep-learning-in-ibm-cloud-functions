# ----------------------------------------------------------
# This script creates Cloud Functions entities in the current 
# namespace that implement the tutorial application.
#
# Replace the following placeholders:
#  <TODO-your-bucket-name>
# ----------------------------------------------------------

# Cloud Object Storage instance name 
COS_INSTANCE_NAME=cloud-object-storage-lite
# Regional bucket in above Cloud Object Storage instance
BUCKET_NAME=<TODO-your-bucket-name>
# Cloud Functions namespace where the tutorial application
# entities will be created
NAMESPACE_NAME=analyze_images

# Create and set namespace
ibmcloud fn namespace create $NAMESPACE_NAME --description "identify objects in images"
ibmcloud fn property set --namespace $NAMESPACE_NAME

# List namespaces and entities in the current namespace
ibmcloud fn namespace list
ibmcloud fn list

# Prepare namespace for Cloud Object Storage triggers
ibmcloud iam authorization-policy-create functions cloud-object-storage "Notifications Manager" --source-service-instance-name $NAMESPACE_NAME --target-service-instance-name $COS_INSTANCE_NAME

# ----------------------------------------------------------
# Perform a task whenever an object is uploaded to a  
# regional Cloud Object Storage bucket
# ----------------------------------------------------------

# Create trigger that fires when a JPG image is uploaded to the specified bucket
ibmcloud fn trigger create bucket_jpg_write_trigger --feed /whisk.system/cos/changes --param bucket $BUCKET_NAME --param suffix ".jpg" --param event_types write
# Display trigger properties
ibmcloud fn trigger get bucket_jpg_write_trigger

# Create a package and display its properties
ibmcloud fn package create manage_pictures
ibmcloud fn package get manage_pictures

# Bind a Cloud Object Storage service instance to the package and display package properties again
ibmcloud fn service bind cloud-object-storage manage_pictures --instance $COS_INSTANCE_NAME
ibmcloud fn package get manage_pictures

# Create an action that performs object detection and display the action's properties OR
# create an action that generates an image caption and display the action's properties
ibmcloud fn action update manage_pictures/bucket_write_action detect_objects.py --kind python:3.7
# ibmcloud fn action update manage_pictures/bucket_write_action detect_objects.js --kind nodejs:10

# ibmcloud fn action update manage_pictures/bucket_write_action generate_image_caption.py --kind python:3.7

ibmcloud fn action get manage_pictures/bucket_write_action

# Create a rule that associates the trigger with the action and display the rule's properties
ibmcloud fn rule create bucket_jpg_write_rule bucket_jpg_write_trigger manage_pictures/bucket_write_action
ibmcloud fn rule get bucket_jpg_write_rule

# Display entities in the current namespace
ibmcloud fn list

# ----------------------------------------------------------
# Perform a task whenever an object is deleted from a 
# regional Cloud Object Storage bucket
# ----------------------------------------------------------

# Create trigger that fires when a JPG image is removed from the specified bucket
ibmcloud fn trigger create bucket_jpg_delete_trigger --feed /whisk.system/cos/changes --param bucket $BUCKET_NAME --param suffix ".jpg" --param event_types delete

# Create an action that removes an annotation file 
ibmcloud fn action update manage_pictures/bucket_delete_action bucket_delete_action.py --kind python:3.7

# Create a rule that associates the trigger with the action
ibmcloud fn rule create bucket_jpg_delete_rule bucket_jpg_delete_trigger manage_pictures/bucket_delete_action

# Display entities in the current namespace
ibmcloud fn list

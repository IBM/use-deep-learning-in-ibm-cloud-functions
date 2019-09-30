REM ----------------------------------------------------------
REM This script creates Cloud Functions entities in the current 
REM namespace that implement the tutorial application.
REM
REM Replace the following placeholders:
REM  <TODO-your-cloud-object-storage-instance-name>
REM  <TODO-your-bucket-name>
REM ----------------------------------------------------------

REM Create and set namespace
ibmcloud fn namespace create analyze_images --description "identify objects in images"
ibmcloud fn property set --namespace analyze_images

REM List namespaces and entities in the current namespace
ibmcloud fn namespace list
ibmcloud fn list

REM Prepare namespace for Cloud Object Storage triggers
ibmcloud iam authorization-policy-create functions cloud-object-storage "Notifications Manager" --source-service-instance-name analyze_images --target-service-instance-name <TODO-your-cloud-object-storage-instance-name>

REM ----------------------------------------------------------
REM Perform a task whenever an object is uploaded to a  
REM regional Cloud Object Storage bucket
REM ----------------------------------------------------------

REM Create trigger that fires when a JPG image is uploaded to the specified bucket
ibmcloud fn trigger create bucket_jpg_write_trigger --feed /whisk.system/cos/changes --param bucket <TODO-your-bucket-name> --param suffix ".jpg" --param event_types write
REM Display trigger properties
ibmcloud fn trigger get bucket_jpg_write_trigger

REM Create a package and display its properties
ibmcloud fn package create manage_pictures
ibmcloud fn package get manage_pictures

REM Bind a Cloud Object Storage service instance to the package and display package properties again
ibmcloud fn service bind cloud-object-storage manage_pictures --instance <TODO-your-cloud-object-storage-instance-name>
ibmcloud fn package get manage_pictures

REM Create an action that performs object detection and display the action's properties OR
REM create an action that generates an image caption and display the action's properties
ibmcloud fn action update manage_pictures/bucket_write_action detect_objects.py --kind python:3.7
REM ibmcloud fn action update manage_pictures/bucket_write_action generate_image_caption.py --kind python:3.7

ibmcloud fn action get manage_pictures/bucket_write_action

REM Create a rule that associates the trigger with the action and display the rule's properties
ibmcloud fn rule create bucket_jpg_write_rule bucket_jpg_write_trigger manage_pictures/bucket_write_action
ibmcloud fn rule get bucket_jpg_write_rule

REM Display entities in the current namespace
ibmcloud fn list

REM ----------------------------------------------------------
REM Perform a task whenever an object is deleted from a 
REM regional Cloud Object Storage bucket
REM ----------------------------------------------------------

REM Create trigger that fires when a JPG image is removed from the specified bucket
ibmcloud fn trigger create bucket_jpg_delete_trigger --feed /whisk.system/cos/changes --param bucket <TODO-your-bucket-name> --param suffix ".jpg" --param event_types delete

REM Create an action that removes an annotation file 
ibmcloud fn action update manage_pictures/bucket_delete_action bucket_delete_action.py --kind python:3.7

REM Create a rule that associates the trigger with the action
ibmcloud fn rule create bucket_jpg_delete_rule bucket_jpg_delete_trigger manage_pictures/bucket_delete_action

REM Display entities in the current namespace
ibmcloud fn list
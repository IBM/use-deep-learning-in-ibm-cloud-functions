@echo off
REM ----------------------------------------------------------
REM This script creates Cloud Functions entities in the current namespace that implement the tutorial application.
REM Prerequisites:
REM  (1) IBM Cloud CLI is installed and included in PATH
REM  (2) IBM Cloud Functions plugin is installed
REM  (3) A Cloud Object Storage instance was provisioned (see create_services.bat)
REM  (4) A regional bucket was created in named Cloud Object Storage instanc
REM Replace the following placeholders:
REM  <TODO-your-bucket-name>
REM ----------------------------------------------------------

REM Cloud Object Storage instance name 
set COS_INSTANCE_NAME=cloud-object-storage-lite
REM Regional bucket in above Cloud Object Storage instance
set BUCKET_NAME=<TODO-your-bucket-name>
REM Cloud Functions namespace where the tutorial application entities will be created
set NAMESPACE_NAME=analyze_images

REM Create and set namespace
ibmcloud fn namespace create %NAMESPACE_NAME% --description "identify objects in images"
ibmcloud fn property set --namespace %NAMESPACE_NAME%

REM List namespaces and entities in the current namespace
ibmcloud fn namespace list
ibmcloud fn list

REM Prepare namespace for Cloud Object Storage triggers
ibmcloud iam authorization-policy-create functions cloud-object-storage "Notifications Manager" --source-service-instance-name %NAMESPACE_NAME% --target-service-instance-name %COS_INSTANCE_NAME%

REM ----------------------------------------------------------
REM Perform a task whenever an object is uploaded to a  
REM regional Cloud Object Storage bucket
REM ----------------------------------------------------------

REM Create trigger that fires when a JPG image is uploaded to the specified bucket
ibmcloud fn trigger create bucket_jpg_write_trigger --feed /whisk.system/cos/changes --param bucket %BUCKET_NAME% --param suffix ".jpg" --param event_types write
REM Display trigger properties
ibmcloud fn trigger get bucket_jpg_write_trigger

REM Create trigger that fires when a PNG image is uploaded to the specified bucket
ibmcloud fn trigger create bucket_png_write_trigger --feed /whisk.system/cos/changes --param bucket %BUCKET_NAME% --param suffix ".png" --param event_types write
REM Display trigger properties
ibmcloud fn trigger get bucket_png_write_trigger

REM Create a package and display its properties
ibmcloud fn package create manage_pictures
ibmcloud fn package get manage_pictures

REM Bind a Cloud Object Storage service instance to the package and display package properties again
ibmcloud fn service bind cloud-object-storage manage_pictures --instance %COS_INSTANCE_NAME%
ibmcloud fn package get manage_pictures

REM Create an action that identifies objects in an image
REM  Use Python implementation
ibmcloud fn action update manage_pictures/bucket_write_action actions/python/detect_objects.py --kind python:3.7
REM  Use Node.js implementation
REM ibmcloud fn action update manage_pictures/bucket_write_action actions/js/detect_objects.js --kind nodejs:10

REM Create an action that generates a caption for an image
REM  Use Python implementation
REM ibmcloud fn action update manage_pictures/bucket_write_action actions/python/generate_image_caption.py --kind python:3.7
REM  Use Node.js implementation
REM ibmcloud fn action update manage_pictures/bucket_write_action actions/js/generate_image_caption.js --kind nodejs:10

REM Display the action's properties
ibmcloud fn action get manage_pictures/bucket_write_action

REM Create a rule that associates the JPG triggers with the action and display the rule's properties
ibmcloud fn rule create bucket_jpg_write_rule bucket_jpg_write_trigger manage_pictures/bucket_write_action
ibmcloud fn rule get bucket_jpg_write_rule

REM Create a rule that associates the JPG triggers with the action and display the rule's properties
ibmcloud fn rule create bucket_png_write_rule bucket_png_write_trigger manage_pictures/bucket_write_action
ibmcloud fn rule get bucket_png_write_rule

REM Display entities in the current namespace
ibmcloud fn list

REM ----------------------------------------------------------
REM Perform a task whenever an object is deleted from a 
REM regional Cloud Object Storage bucket
REM ----------------------------------------------------------

REM Create trigger that fires when a JPG image is removed from the specified bucket
ibmcloud fn trigger create bucket_jpg_delete_trigger --feed /whisk.system/cos/changes --param bucket %BUCKET_NAME% --param suffix ".jpg" --param event_types delete
REM Create trigger that fires when a PNG image is removed from the specified bucket
ibmcloud fn trigger create bucket_png_delete_trigger --feed /whisk.system/cos/changes --param bucket %BUCKET_NAME% --param suffix ".png" --param event_types delete

REM Create an action that removes an annotation file
REM  Python implementation
ibmcloud fn action update manage_pictures/bucket_delete_action actions/python/delete_annotation.py --kind python:3.7
REM  Node.js implementation
REM ibmcloud fn action update manage_pictures/bucket_delete_action actions/js/delete_annotation.js --kind nodejs:10

REM Create rules that associate the triggers with the action
ibmcloud fn rule create bucket_jpg_delete_rule bucket_jpg_delete_trigger manage_pictures/bucket_delete_action
ibmcloud fn rule create bucket_png_delete_rule bucket_png_delete_trigger manage_pictures/bucket_delete_action

REM Display entities in the current namespace
ibmcloud fn list

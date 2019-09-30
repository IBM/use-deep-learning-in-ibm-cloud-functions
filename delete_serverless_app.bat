REM ----------------------------------------------------------
REM This script removes Cloud Functions entities from the 
REM selected namespace that implement the tutorial application.
REM ----------------------------------------------------------

ibmcloud fn property set --namespace analyze_images

REM List entities in the current namespace
ibmcloud fn list

REM Delete the rules
ibmcloud fn rule delete bucket_jpg_write_rule
ibmcloud fn rule delete bucket_jpg_delete_rule

REM Delete Cloud Object Storage triggers
ibmcloud fn trigger delete bucket_jpg_write_trigger
ibmcloud fn trigger delete bucket_jpg_delete_trigger

REM Delete actions
ibmcloud fn action delete manage_pictures/bucket_write_action
ibmcloud fn action delete manage_pictures/bucket_delete_action

REM Delete package
ibmcloud fn package delete manage_pictures

REM List entities in the current namespace
ibmcloud fn list

REM delete namespace
ibmcloud fn namespace delete analyze_images

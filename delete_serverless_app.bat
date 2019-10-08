@echo off
REM ----------------------------------------------------------
REM This script removes Cloud Functions entities from the 
REM selected namespace that implement the tutorial application.
REM Prerequisites:
REM  (1) IBM Cloud CLI is installed and included in PATH
REM  (2) IBM Cloud Functions plugin is installed
REM ----------------------------------------------------------

REM Cloud Functions namespace where the tutorial application entities were created
set NAMESPACE_NAME=analyze_images

ibmcloud fn property set --namespace %NAMESPACE_NAME%

REM List entities in the current namespace
ibmcloud fn list

REM Delete the rules
ibmcloud fn rule delete bucket_jpg_write_rule
ibmcloud fn rule delete bucket_png_write_rule
ibmcloud fn rule delete bucket_jpg_delete_rule
ibmcloud fn rule delete bucket_png_delete_rule

REM Delete Cloud Object Storage triggers
ibmcloud fn trigger delete bucket_jpg_write_trigger
ibmcloud fn trigger delete bucket_png_write_trigger
ibmcloud fn trigger delete bucket_jpg_delete_trigger
ibmcloud fn trigger delete bucket_png_delete_trigger

REM Delete actions
ibmcloud fn action delete manage_pictures/bucket_write_action
ibmcloud fn action delete manage_pictures/bucket_delete_action

REM Delete package
ibmcloud fn package delete manage_pictures

REM List entities in the current namespace
ibmcloud fn list

REM delete namespace
ibmcloud fn namespace delete %NAMESPACE_NAME%

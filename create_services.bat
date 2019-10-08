@echo off
REM ------------------------------------------------------------------------------------
REM This script creates the Cloud services that the tutorial application utilizes:
REM - Cloud Object Storage https://cloud.ibm.com/catalog/services/cloud-object-storage
REM Prerequisites:
REM  (1) IBM Cloud CLI is installed and included in PATH
REM ------------------------------------------------------------------------------------

REM Cloud Object Storage instance name
REM If you change the name you must also change the *_serverless_app.* scripts
set COS_INSTANCE_NAME=cloud-object-storage-lite

REM Service plan name
REM lite (free), or standard
set SERVICE_PLAN_NAME=standard

REM Resource group
set RESOURCE_GROUP=default

REM Create a Cloud Object Storage service instance (Lite/free plan) in the default resource group
REM For help with this command run "ibmcloud resource service-instance-create --help"
ibmcloud resource service-instance-create %COS_INSTANCE_NAME% cloud-object-storage %SERVICE_PLAN_NAME% global -g %RESOURCE_GROUP%

REM Create a service key with write access in this instance
REM For help with this command run "ibmcloud resource service-key-create --help" 
ibmcloud resource service-key-create serverless-write-access Writer --instance-name %COS_INSTANCE_NAME%

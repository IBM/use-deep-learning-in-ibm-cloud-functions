## Create a serverless app that annotates images (text, video, audio, ...) 


In this tutorial you will create a serverless application using [IBM Cloud Functions](https://cloud.ibm.com/functions/) that monitors the content of a Cloud Object Storage bucket for changes using [triggers](https://cloud.ibm.com/docs/openwhisk?topic=cloud-functions-pkg_obstorage#pkg_obstorage_ev). Whenever an image is uploaded to the bucket a Cloud Object Storage trigger fires and invokes an action that analyzes the image content using a deep learning microservice from the [Model Asset Exchange](https://developer.ibm.com/exchanges/models/).

![serverless scenario](doc/images/scenario.png)

Out of the box the application detects objects in a JPG image but you can easily modify the application to generate image captions or perform other kinds of analysis on images or other media types, such as text, audio, or video. Source code is included for Python and Node.js.

![Cloud Functions activity log](doc/images/test_output.png)

## Steps

If you are not familiar with IBM Cloud Functions or Cloud Object Storage, follow the detailed deployment instructions in this tutorial.

### Quickstart

1. Create a [Cloud Object Storage](https://cloud.ibm.com/catalog/services/cloud-object-storage) service instance in the IBM Cloud.
1. Create service credentials for this service instance that the serverless app will use to access the bucket.
1. Create a regional bucket (in `us-south`, `us-east`, or `eu-gb`) in this instance.
1. In a terminal window verify that your IBM Cloud CLI installation is at version 0.19 or later.
1. Customize `create_serverless_app.sh` by replacing the `<TODO-...>` placeholders.
1. Run `create_serverless_app.sh` to create the application.
1. Open the [Cloud Functions dashboard](https://cloud.ibm.com/functions/dashboard) in a web browser.
1. Upload a JPG image to the regional bucket and monitor the Cloud Functions activity log.
   ![Cloud Functions activity log](doc/images/monitor_functions.png)
1. Upload a PNG image or any other kind of media to the bucket. No action should be triggered.
1. Delete a previously uploaded JPG image. The corresponding JSON annotations file should be automatically removed.

To uninstall the application run `delete_serverless_app.sh` .

## License

[Apache 2.0](LICENSE)
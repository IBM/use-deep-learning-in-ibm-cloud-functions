/*
This code implements a Cloud Functions action, which
performs Object Detection on an image that is stored
in Cloud Object Storage.

The action is preconfigured to utilize an evaluation instance
of the Object Detector microservice from the Model Asset Exchange:
https://developer.ibm.com/exchanges/models/all/max-object-detector/
*/

'use strict';

// Required libraries
const fileType = require('file-type');
const AWS = require('ibm-cos-sdk');
const path = require('path');
const rp = require('request-promise');

async function main(args) {

    function createCOSClient(endpoint = 'https://s3.us.cloud-object-storage.appdomain.cloud', 
                             apikey, 
                             authEndpoint = 'https://iam.cloud.ibm.com/identity/token', 
                             instanceId) {
                                 
        const config = {
            endpoint: endpoint,
            apiKeyId: apikey,
            ibmAuthEndpoint: authEndpoint,
            serviceInstanceId: instanceId,
        };

        return new AWS.S3(config);
    }

    if ((! args.hasOwnProperty('__bx_creds')) ||
        (! args['__bx_creds'].hasOwnProperty('cloud-object-storage')) ||
        (! args['__bx_creds']['cloud-object-storage'].hasOwnProperty('apikey')) ||
        (! args['__bx_creds']['cloud-object-storage'].hasOwnProperty('resource_instance_id'))) {
            throw Error('The action requires access to Cloud Object Storage credentials.');
    }

    const cos = createCOSClient(args['endpoint'],
                                args['__bx_creds']['cloud-object-storage']['apikey'],
                                undefined,
                                args['__bx_creds']['cloud-object-storage']['resource_instance_id'])

    if (! args.hasOwnProperty('bucket')) {
        throw Error('Required parameter "bucket" is missing.')
    }

    if (! args.hasOwnProperty('key')) {
        throw Error('Required parameter "key" is missing.')
    }

    var step = undefined;

    try {

        step = 'load object from COS bucket'
        // Load uploaded object from Cloud Object Storage
        const uploaded_object = await cos.getObject({
                                            Bucket: args['bucket'], 
                                            Key: args['key']
                                        }).promise()

        // the uploaded_object['Body'] property contains the data

        // URL of a MAX Object Detector microservice evaluation instance
        const host = 'max-object-detector.max.us-south.containers.appdomain.cloud';

        // prepare payload for object detection analysis call:
        //  - image (required; a JPG or PNG-encoded picture)
        //  - threshold (optional; numeric between 0 (low confidence) and 1
        //     (high confidence))
        // https://developer.ibm.com/exchanges/models/all/max-object-detector/

        var options = {
            method: 'POST',
            uri: `http://${host}/model/predict`,
            formData: {
                threshold: '0.5',
                image: {
                    value: uploaded_object['Body'],
                    options: {
                        filename: args['key']
                    }
                }
            }
        };

        // If the object's mimetype can be determined, add it to the request
        // payload.
        if(fileType(uploaded_object['Body'])) {
            options['formData']['image']['options']['contentType'] = 
                fileType(uploaded_object['Body'])['mime']
        }

        step = 'detect objects'

        // Invoke the prediction endpoint of the Object Detection
        // microservice to analyze the loaded object.
        const response = await rp(options);

        // generate annotations file key from the object's key
        const key_id = `annotations/${path.parse(args['key']).name}.json`;

        step = 'save annotation in COS bucket'

        // Save annotation file in the bucket where the object is stored
        await cos.putObject({
            Bucket: args['bucket'], 
            Key: key_id,
            Body: JSON.stringify(JSON.parse(response)['predictions'])
            }).promise()
        
        return {
            bucket: args['bucket'],
            key: args['key'],
            annotation_key: key_id,
            annotation_type: 'max-object-detector'
        }
    }
    catch(err) {
        console.error(`Action step "${step}" failed: ${err}`)
        throw Error(`Action step "${step}" failed: ${err}`)
    }
}
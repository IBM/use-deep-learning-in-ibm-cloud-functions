/*
This code implements a Cloud Functions action, which
deletes an annotations file from Cloud Object Storage.
*/

'use strict';

// Required libraries
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

    try {

        // Remove annotation from Cloud Object Storage
        await cos.deleteObject({
                                Bucket: args['bucket'], 
                                Key: `annotations/${path.parse(args['key']).name}.json`
                               }).promise()

        return {};
    }
    catch(err) {
        // log error but don't raise
        console.error(`Action failed: ${err}`)
    }
}
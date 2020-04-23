"""
This code implements a Cloud Functions action, which
generates a caption for an image that is stored
in Cloud Object Storage.

The action is preconfigured to utilize an evaluation instance
of the Image Caption Generator microservice from the Model Asset
Exchange:
https://developer.ibm.com/exchanges/models/all/max-image-caption-generator/
"""

import ibm_boto3
from ibm_botocore.client import Config
import json
import mimetypes
import os
import requests


def main(args):
    """
    This action performs the following tasks:
    - load the object that is identified by the
      args['bucket'] and args['key'] parameters
    - submit a prediction request to the MAX Object Detector
      microservice
    - store the prediction results as a JSON file in
      in args['bucket']

    :param args: Action parameters. The following
     properties must be defined in this dict: bucket,
     key, ...
    :type args: dict
    :raises ValueError: a required parameter is missing or invalid
    :raises Exception: a fatal error occured
    :return: A dictionary containing the bucket, key, and
    annotation_key properties.
    :rtype: dict
    """

    # debug output only
    # print('action parameters: {}'.format(args))

    # Try to create a Cloud Object Storage client using the
    # connectivity information from the action arguments
    cos = createCOSClient(args)

    # verify that this action's package was bound
    # to a Cloud Object Storage instance
    if not cos:
        raise ValueError('The action requires access to '
                         'Cloud Object Storage credentials.')

    # get required action parameters: bucket and object key
    bucket = args.get('bucket')
    key = args.get('key')

    # verify that the required parameters were specified
    if not bucket:
        raise ValueError('Required parameter "bucket" is missing.')
    if not key:
        raise ValueError('Required parameter "key" is missing.')

    # try to guess the mimetype of the object that's identified by "key"
    (mimetype, encoding) = mimetypes.guess_type(key)

    if not mimetype:
        raise ValueError('The object\'s mimetype cannot be determined.')

    try:
        # get added/updated object from bucket
        object = cos.get_object(Bucket=bucket,
                                Key=key)
        # read object content
        content = object['Body'].read()

        # prepare payload for object detection analysis call:
        #  - image (required)
        # https://developer.ibm.com/exchanges/models/all/generate-image-caption/
        files = {
           'image': (key, content, mimetype)
        }

        # For illustrative purposes we use the URL of a public MAX Image
        # Caption Generator microservice evaluation instance.
        # This instance must not be used for production purposes.
        host = 'max-image-caption-generator.' \
               'codait-prod-41208c73af8fca213512856c7a09db52-0000.us-east.'\
               'containers.appdomain.cloud'

        # Invoke the prediction endpoint of the Image Caption Generator
        # microservice to analyze the loaded object.
        response = requests.post('http://{}/model/predict'.format(host),
                                 files=files)

        if response.status_code == 200:
            # generate an object key for the annotation file
            key_id = "annotations/{}.json".format(os.path.splitext(key)[0])
            # save prediction result in the same bucket
            cos.put_object(Body=json.dumps(response.json().get('predictions')),
                           Bucket=bucket,
                           Key=key_id)
        else:
            # The prediction request failed. Log information
            # and raise an exception.
            print(response.status_code)
            print(response.text)
            raise Exception('Object Detection for image {} failed.'
                            'HTTP response code: {}.'
                            'Response message: {}.'
                            .format(key, response.status_code, response.text))
    except Exception as e:
        print('Action failed: {}'.format(e))
        raise e

    # return results (that can be processed by the caller or another action)
    return {
            "bucket": bucket,
            "key": key,
            "annotation_key": key_id,
            "annotation_type": "max-image-caption-generator"
           }


def createCOSClient(args):
    """
    Create a ibm_boto3.client using the connectivity information
    contained in args.

    :param args: action parameters
    :type args: dict
    :return: An ibm_boto3.client
    :rtype: ibm_boto3.client
    """

    # if a Cloud Object Storage endpoint parameter was specified
    # make sure the URL contains the https:// scheme or the COS
    # client cannot connect
    if args.get('endpoint') and not args['endpoint'].startswith('https://'):
        args['endpoint'] = 'https://{}'.format(args['endpoint'])

    # set the Cloud Object Storage endpoint
    endpoint = args.get('endpoint',
                        'https://s3.us.cloud-object-storage.appdomain.cloud')

    # extract Cloud Object Storage service credentials
    cos_creds = args.get('__bx_creds', {}).get('cloud-object-storage', {})

    # set Cloud Object Storage API key
    api_key_id = \
        args.get('apikey',
                 args.get('apiKeyId',
                          cos_creds.get('apikey',
                                        os.environ
                                        .get('__OW_IAM_NAMESPACE_API_KEY')
                                        or '')))

    if not api_key_id:
        # fatal error; it appears that no Cloud Object Storage instance
        # was bound to the action's package
        return None

    # set Cloud Object Storage instance id
    svc_instance_id = args.get('resource_instance_id',
                               args.get('serviceInstanceId',
                                        cos_creds.get('resource_instance_id',
                                                      '')))
    if not svc_instance_id:
        # fatal error; it appears that no Cloud Object Storage instance
        # was bound to the action's package
        return None

    ibm_auth_endpoint = args.get('ibmAuthEndpoint',
                                 'https://iam.cloud.ibm.com/identity/token')

    # Create a Cloud Object Storage client using the provided
    # connectivity information
    cos = ibm_boto3.client('s3',
                           ibm_api_key_id=api_key_id,
                           ibm_service_instance_id=svc_instance_id,
                           ibm_auth_endpoint=ibm_auth_endpoint,
                           config=Config(signature_version='oauth'),
                           endpoint_url=endpoint)

    # Return Cloud Object Storage client
    return cos

import ibm_boto3
from ibm_botocore.client import Config
import os


def main(args):

    resultsGetParams = getParamsCOS(args)
    cos = resultsGetParams.get('cos')
    params = resultsGetParams.get('params')
    bucket = params.get('bucket')
    key = params.get('key')

    try:
        key_id = "{}_annotation.json".format(os.path.splitext(key)[0])
        cos.Object(bucket, key_id).delete()

    except Exception as e:
        print(e)

    return {}


def getParamsCOS(args):
    if args.get('endpoint') and not args['endpoint'].startswith('https://'):
        args['endpoint'] = 'https://{}'.format(args['endpoint'])

    endpoint = args.get('endpoint',
                        'https://s3.us.cloud-object-storage.appdomain.cloud')

    api_key_id = args.get('apikey',
                          args.get('apiKeyId',
                                   args.get('__bx_creds', {}).get('cloud-object-storage', {}).get('apikey', os.environ.get('__OW_IAM_NAMESPACE_API_KEY') or '')))
    service_instance_id = args.get('resource_instance_id',
                                   args.get('serviceInstanceId', args.get('__bx_creds', {}).get('cloud-object-storage', {}).get('resource_instance_id', '')))
    ibm_auth_endpoint = args.get('ibmAuthEndpoint',
                                 'https://iam.cloud.ibm.com/identity/token')
    params = {}
    params['bucket'] = args.get('bucket')
    params['key'] = args.get('key')
    params['body'] = args.get('body')
    if not api_key_id:
        return {'cos': None, 'params': params}
    cos = ibm_boto3.resource('s3',
                             ibm_api_key_id=api_key_id,
                             ibm_service_instance_id=service_instance_id,
                             ibm_auth_endpoint=ibm_auth_endpoint,
                             config=Config(signature_version='oauth'),
                             endpoint_url=endpoint)
    return {'cos': cos, 'params': params}

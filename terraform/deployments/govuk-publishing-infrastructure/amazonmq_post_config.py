import base64

import re
import urllib.error

from urllib import request


def raise_if_not_an_amazonmq_url(url):
    if re.fullmatch(r'.*\.mq\.[a-z0-9_-]+\.amazonaws\.com/.*', url) is None:
        raise ValueError(f'Not a valid AmazonMQ URL: {url}')


def auth_digest(username, password):
    credentials = f'{username}:{password}'
    return base64.b64encode(credentials.encode('UTF8'))


def add_headers(req, event):
    auth_header_value = b'Basic ' + \
        auth_digest(event['username'], event['password'])
    req.add_header('Authorization', auth_header_value)
    req.add_header('Content-type', 'application/json')
    return req


def lambda_handler(event, _):
    raise_if_not_an_amazonmq_url(event['url'])

    raw_json = base64.b64decode(event['json_b64'])
    req = request.Request(event['url'], data=raw_json,
                          method='POST', unverifiable=True)
    add_headers(req, event)

    print('Posting JSON to ', event['url'])
    try:
        resp = request.urlopen(req)
        status = resp.status
        response_body = resp.read()
    except urllib.error.HTTPError as e:
        status = e.status
        response_body = e.read().decode()

    print('response status: ', status)
    print('response body: ', response_body)

    return {
        'statusCode': status,
        'body': response_body
    }

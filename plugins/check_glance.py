#!/usr/bin/env python

# Dependencies of this program
#       python module: python-glanceclient, cryptography, jsonpointer, functools32
#
#
# Copyright 2015 Hua Li <lihua88@bu.edu>
#
# Released under the same terms as Sensu (the MIT license);
# see LICENSE for details.

import sys
import argparse
import logging
import json
import keystoneclient.v2_0.client as ksclient
import glanceclient as glclient

STATE_OK = 0
STATE_WARNING = 1
STATE_CRITICAL = 2
STATE_UNKNOWN = 3

logging.basicConfig(level=logging.INFO)

parser = argparse.ArgumentParser(description='Check OpenStack Glance status')
parser.add_argument('--auth-url', metavar='URL', type=str,
                    required=True,
                    help='Keystone URL')
parser.add_argument('--username', metavar='username', type=str,
                    required=True,
                    help='username for authentication')
parser.add_argument('--password', metavar='password', type=str,
                    required=True,
                    help='password for authentication')
parser.add_argument('--tenant', metavar='tenant', type=str,
                    required=True,
                    help='tenant name for authentication')
parser.add_argument('--endpoint', metavar='endpoint', type=str,
                    required=True,
                    help='Endpoint for glance server')

args = parser.parse_args()

try:
    keystone = ksclient.Client(username=args.username,
                      tenant_name=args.tenant,
                      password=args.password,
                      auth_url=args.auth_url,
                      region_name=args.region_name,
                      endpoint_type="internalURL")

    print "Connected keystone!"
    glance = glclient.Client('2',token=keystone.auth_token,endpoint = args.endpoint,
                      endpoint_type="internalURL")

    print "Connected glance server!"
    images = glance.images.list()

    active_counter=0
    saving_counter=0
    queued_counter=0
    deleted_counter=0

    # loop image object in the list
    for image in images:
        #print "Image:%s\tStatus:%s" % (image.name,image.status)
        if image.status == 'active':
             active_counter+=1
        elif image.status == 'saving':
             saving_counter+=1
        elif image.status == 'queued':
             queued_counter+=1
        elif image.status == 'deleted':
             deleted_counter+=1

except Exception as e:
    print str(e)
    exit(STATE_CRITICAL)

print "Active:%d\tSaving:%d\tQueued%d\tDeleted\t%d"%(active_counter, saving_counter, queued_counter, deleted_counter)
exit_state = STATE_OK

exit(exit_state)


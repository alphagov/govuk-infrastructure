import boto3
import hashlib
import json
import logging
import urllib.request, urllib.error, urllib.parse
import os
import random
import string

INGRESS_PORTS = os.getenv( 'PORTS', "80").split(",")
SERVICE = os.getenv( 'SERVICE', "CLOUDFRONT")
NAME = os.getenv( 'PREFIX_NAME', "AUTOUPDATE_CF")
VPC_ID= os.getenv( 'VPC_ID',"")
REGION= os.getenv( 'REGION',"us-east-1")
ALB_ARN = os.getenv( 'ALB_ARN',"")
AD_SG= os.getenv( 'AD_SG',"")
NRANGES=0
NRULES=60

def lambda_handler(event, context):

    global NRANGES
    # Set up logging
    if len(logging.getLogger().handlers) > 0:
        logging.getLogger().setLevel(logging.ERROR)
    else:
        logging.basicConfig(level=logging.DEBUG)

    # Set the environment variable DEBUG to 'true' if you want verbose debug details in CloudWatch Logs.
    try:
        if os.environ['DEBUG'] == 'true':
            logging.getLogger().setLevel(logging.INFO)
    except KeyError:
        pass
    # SNS message notification event when the ip ranges document is rotated
    message = json.loads(event['Records'][0]['Sns']['Message'])

    ip_ranges = json.loads(get_ip_groups_json(message['url'], message['md5']))
    cf_ranges = get_ranges_for_service(ip_ranges, SERVICE)

    #Number of security group rules required as per the total range count
    NRANGES=len(cf_ranges)*len(INGRESS_PORTS)

    #Update SGs with the new ranges
    update_security_groups(cf_ranges)
    apply_security_groups_alb()

def update_security_groups(new_ranges):
    global VPC_ID

    #Creating ec2 boto3 client
    client = boto3.client('ec2',region_name=REGION)

    if VPC_ID=="":
        result=client.describe_vpcs(Filters=[{'Name':'isDefault','Values': ['true']},])
        VPC_ID=result["Vpcs"][0]['VpcId']

    #To number of SGs to update
    rangeToUpdate = get_security_groups_for_update(client,True)

    if len(rangeToUpdate) == 0:

            logging.warning( 'No groups to {}'.format("update") )
    else:
        update_security_group(client, rangeToUpdate, new_ranges)


def update_security_group(client, rangeToUpdate, new_ranges):

        old_prefixes = list()
        to_revoke = {}
        to_add = list()
        final_add={}
        total=0

        for each_grp in rangeToUpdate['SecurityGroups']:
            to_revoke[each_grp['GroupId']]=set()

            # If there are any exixting ranges in the SG, compares and add it to the revoke list if necessary
            to_revoke_sg=0
            if len(each_grp['IpPermissions']) > 0:

                for permission in each_grp['IpPermissions']:

                    for range in permission['IpRanges']:
                            cidr = range['CidrIp']
                            old_prefixes.append(cidr)
                            if new_ranges.count(cidr) == 0:
                                to_revoke_sg+=1
                                to_revoke[each_grp['GroupId']].add(cidr)

                #Available slots in the SGs are the rules are revoked
                remain_rules=NRULES-(len(each_grp['IpPermissions'][0]['IpRanges'])*len(INGRESS_PORTS))+to_revoke_sg
                logging.info(("Total number of rules available in " + each_grp['GroupId'] + "are " + str(remain_rules)))
                final_add[each_grp['GroupId']]=remain_rules
                total+=remain_rules

            else:
                final_add[each_grp['GroupId']]=NRULES
                total+=NRULES
        #Compares and identifies the new range to add from the service ranges list
        for range in new_ranges:
            if (old_prefixes.count(range) == 0):
                to_add.append({ 'CidrIp': range })
                logging.info((" Range to be added: " + range))
        count=0
        for group in to_revoke:
            if len(to_revoke[group])>0:
                count+=len(to_revoke[group])
                logging.info(("Rules that have to be revoked for  " + str(to_revoke[group])))
                revoke_permissions(client,group,to_revoke[group])
            else:
                logging.info(("No rules were identified to be revoked in the security group "+group))

        logging.info(("Total number of rules to be revoked in all the security groups are "  + str(count*len(INGRESS_PORTS))))
        logging.info(("Total number of rules to be added "  + str(len(to_add)*len(INGRESS_PORTS))))
        logging.info(("Rules to add "  + str(to_add)))

        dynamic_rule_add(client, final_add,to_add,total)

def dynamic_rule_add(client,final_add,to_add,total):

    random_str=''.join(random.choices(string.ascii_uppercase +string.digits, k = 3))

    if total< (len(to_add)*len(INGRESS_PORTS)):
        security_group = client.create_security_group(
                                Description=NAME+"-"+random_str,
                                GroupName=NAME+"-"+random_str,
                                VpcId=VPC_ID,
                                DryRun=False
                                )
        all_sgs=list(final_add.keys())
        response = client.describe_network_interfaces(
                                Filters=[
                                        {
                                            'Name': 'group-id',
                                            'Values': all_sgs
                                        },
                                    ]
                                 )

        final_add[security_group['GroupId']]=NRULES
        all_sgs=list(final_add.keys())

        for each_eni in response['NetworkInterfaces']:

            response = client.modify_network_interface_attribute(
                                    Groups=all_sgs,
                                    NetworkInterfaceId=each_eni["NetworkInterfaceId"],
                                )

    for each_grp in final_add:

        num_accomodate=final_add[each_grp]//len(INGRESS_PORTS)
        remain_per_grp=final_add[each_grp]%len(INGRESS_PORTS)
        logging.info(("Number of rules can security group "+each_grp +" accomodate: "+str(num_accomodate*len(INGRESS_PORTS))))


        for each_proto in INGRESS_PORTS:
            permission = { 'ToPort': int(each_proto), 'FromPort': int(each_proto), 'IpProtocol': 'tcp'}
            add_params = {
                'ToPort': permission['ToPort'],
                'FromPort': permission['FromPort'],
                'IpRanges': to_add[0:num_accomodate],
                'IpProtocol': permission['IpProtocol']
                }

            client.authorize_security_group_ingress(GroupId=each_grp, IpPermissions=[add_params])
            logging.info(("Modified "  + str(len(to_add[0:num_accomodate]))+" rules on security group "+each_grp+" for the port "+each_proto))

        to_add=to_add[num_accomodate:]


def revoke_permissions(client,group,to_revoke):


    #Revoked rules in each SG for every port number
    for each_proto in INGRESS_PORTS:
        permission = { 'ToPort': int(each_proto), 'FromPort': int(each_proto), 'IpProtocol': 'tcp'}
        revoke_params = {
            'ToPort': permission['ToPort'],
            'FromPort': permission['FromPort'],
            'IpRanges': [{'CidrIp': iprange} for iprange in to_revoke],
            'IpProtocol': permission['IpProtocol']
        }

        client.revoke_security_group_ingress(GroupId=group, IpPermissions=[revoke_params])

        logging.info(("Revoked "  + str(len(to_revoke))+" rules from the security group "+group+" with port "+each_proto))
        logging.info(("Ranges revoked from the security group "+group+" are: "+str(to_revoke)))

def create_security_groups(client,response):

    num_sgs=len(response['SecurityGroups'])
    logging.info(('Found ' + str(num_sgs) + ' security groups'))

    total_sgs_required=NRANGES//NRULES

    if NRANGES%NRULES>0:
        total_sgs_required+=1
    logging.info(('Total number of security groups required to add all the rules: ' + str(total_sgs_required)))

    to_create_sgs=0

    if num_sgs<total_sgs_required:
        to_create_sgs=total_sgs_required-num_sgs
    logging.info(('Total number of security groups to be created: ' + str(to_create_sgs)))

    #Creates SGs based on the total number of rules that are required to be added
    created_sgs=[]

    for sg in range(to_create_sgs):
        random_str=''.join(random.choices(string.ascii_uppercase +string.digits, k = 3))
        security_group = client.create_security_group(
                                Description=NAME+"-"+random_str,
                                GroupName=NAME+"-"+random_str,
                                VpcId=VPC_ID,
                                DryRun=False
                                )
        created_sgs.append(security_group['GroupId'])
        response = client.create_tags(Resources=created_sgs,
                                      Tags=[{
                                                'Key': 'PREFIX_NAME',
                                                'Value': NAME,
                                            },
                                    ],)

    return get_security_groups_for_update(client)

def get_security_groups_for_update(client,create=False):
    filters = [
                { 'Name': "tag-key", 'Values': ['PREFIX_NAME'] },
                { 'Name': "tag-value", 'Values': [NAME] },
                { 'Name': "vpc-id", 'Values': [VPC_ID] }
            ]

    #Extracting specific security groups with tags
    response = client.describe_security_groups(Filters=filters)

    #Return list of all security groups if none to be craeted
    if create==False:
        return response
    else:
        return create_security_groups(client,response)

def get_ip_groups_json(url, expected_hash):

    logging.info("Updating from " + url)

    response = urllib.request.urlopen(url)
    ip_json = response.read()

    m = hashlib.md5()
    m.update(ip_json)
    hash = m.hexdigest()

    if hash != expected_hash:
        raise Exception('MD5 Mismatch: got ' + hash + ' expected ' + expected_hash)

    return ip_json

def get_ranges_for_service(ranges, service):

    service_ranges = list()

    for prefix in ranges['prefixes']:
        if prefix['service'] == service:
            service_ranges.append(prefix['ip_prefix'])

    logging.info(('Found ' + service + ' ranges: ' + str(len(service_ranges))))
    return service_ranges

def apply_security_groups_alb():

    #Creating ec2 boto3 client
    ec2_client = boto3.client('ec2',region_name=REGION)

    response=get_security_groups_for_update(ec2_client, False)
    new_security_groups=[sg['GroupId'] for sg in response['SecurityGroups']]
    new_security_groups.extend(AD_SG.split(","))

    #Creating elbv2 boto3 client
    elbv2_client = boto3.client('elbv2',region_name=REGION)

    response = elbv2_client.describe_load_balancers(LoadBalancerArns=[ ALB_ARN,],)
    existing_security_groups = [sg for lb in response['LoadBalancers'] for sg in lb['SecurityGroups']]

    if set(new_security_groups) != set (existing_security_groups):
        response = elbv2_client.set_security_groups(
            LoadBalancerArn=ALB_ARN,
            SecurityGroups=new_security_groups,
        )

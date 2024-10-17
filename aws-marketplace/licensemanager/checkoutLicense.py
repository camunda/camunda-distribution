import boto3
import os
from datetime import datetime
import uuid
import sys

client = boto3.client('license-manager', region_name='us-east-1')

def checkoutLic():
    try:
        response = client.checkout_license(
            ProductSKU="cc2bd756-6b60-48aa-b312-e97293f0d670",
            CheckoutType='PROVISIONAL',
            KeyFingerprint="aws:294406891311:AWS/Marketplace:issuer-fingerprint",
            Entitlements=[
                {
                    'Name': 'AWS::Marketplace::Usage',
                    'Unit': 'None',
                },
            ],
            ClientToken=str(uuid.uuid4())
        )
        print('Check out license successful '+str(response))
        if len(response['EntitlementsAllowed'])>0 and response['EntitlementsAllowed'][0]['Value'] == "Enabled":
            return True
        else:
            print('Insufficient or expired license')
            return False
    except Exception as e:
        print("Error could not call LM checkout api **" + str(e))
        return False

if __name__ == "__main__":
    returned = checkoutLic()
    if returned:
        sys.exit(0)
    else:
        sys.exit(1)


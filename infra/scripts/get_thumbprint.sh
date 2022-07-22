#!/bin/bash
# Instructions on how to get the thumbprint
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
# Get the certificate and output to file
openssl s_client -servername token.actions.githubusercontent.com -showcerts -connect token.actions.githubusercontent.com:443 < /dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sed "0,/-END CERTIFICATE-/d" > certificate.crt
# Use file as input, get the fingerprint, don't output encoding, select 2 feilds, delete colons, transform upper to lower
openssl x509 -in certificate.crt -fingerprint -noout | cut -f2 -d'=' | tr -d ':' | tr '[:upper:]' '[:lower:]'
# Clean up
rm certificate.crt
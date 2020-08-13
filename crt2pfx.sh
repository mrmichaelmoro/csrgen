#!/bin/bash

###########################################################
# Converts a X509 certificate into PFX format
#
# Assumes all of the necessary files are in the current 
# working directory. 
#
# Arg 1: domain (ie. www.domain.com)
# Arg 2: Root CA (optional, takes default configured below)
###########################################################

# Default Root CA used to sign certificate. 
DEF_ROOT_CA=DigiCertCA.crt

# Domain name is needed as files will be named with this.
if [ -z $1 ]; then
	echo "[ ERROR ]: Specify site to export key for."
	echo
	echo "[ USAGE ]: $0 www.domain.com"
	echo
	exit
fi

# Sets the ROOT CA file
if [ -z $2 ]; then
	ROOT_CA=$DEF_ROOT_CA
else
	ROOT_CA=$2
fi

# Checks for existance of RootCA file.
if [ ! -f $ROOT_CA ]; then
	echo
	echo "[ ERROR ]: Root CA file '$ROOT_CA' not found"
	echo
	exit 3
fi

# Variables - Filename assumptions. Not a problem if you used
# csrgen and generate_rsa_key scripts in this repo.
CERTNAME=$1
PRIVATE_KEY=$CERTNAME.pem
CERT_FILE=$CERTNAME.crt
ALT_CERT_FILE=`echo $CERTNAME | sed 's/\./\_/g'`".crt"
PFXOUT=$CERTNAME.pfxt

# Generates a random password for PFX signing
PFXPASS=`openssl rand -base64 10`

# Checks if the X509 certificate exists. Our provider renames
# the file to include underscores instead of dots to avoid
# filesystem issues (ALT_CERT_NAME).
if [ -f $CERT_FILE ]; then
	ORIG_CERT=$CERT_FILE
elif [[ -f $ALT_CERT_FILE ]]; then
	ORIG_CERT=$ALT_CERT_FILE
else
	echo
	echo "[ ERROR ]: Could not locate certificate files."
	echo
	exit 2
fi

# openssl command to export to PKCS12
openssl pkcs12 -export -out $PFXOUT -inkey $PRIVATE_KEY -in $ORIG_CERT -certfile $ROOT_CA -password pass:$PFXPASS

# Checks if the file was generated and not ZERO size
if [[ ! -f $PFXOUT || -s $PFXPASS ]]; then
	echo 
	echo "Unable to export certificate. OpenSSL exited with code [ $? ]."
	echo
	exit 1
fi

# Saves the password to a file and outputs the details
# of the export
echo $PFXPASS > pfxpass.txt
echo
echo "PFX Cert: $PFXOUT"
echo
echo "Password : $PFXPASS"
echo
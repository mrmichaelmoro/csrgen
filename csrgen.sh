#!/bin/bash

if [ -z $1 ]; then
	echo "[ ERROR ]: Specify site to create key for."
	echo
	echo "[ USAGE ]: $0 www.domain.com"
	echo
	exit
fi

CERTNAME=$1

echo

if [ ! -f $CERTNAME.key ]; then
	echo "[ ERROR ]: Key for cert signing '$CERTNAME.key' could not be found. Exiting.."
	echo
	exit
fi

if [ ! -f ssl.cf ]; then
        echo "[ ERROR ]: Certificate configuration file could not be found. Exiting..."
        echo
        exit
else
	if [[ "$CERTNAME" != "wildcard"* ]]; then
		grep $CERTNAME ssl.cf > /dev/null
		if [ $? -ne 0 ]; then
			echo "[ ERROR ]: Configuration file is not configured for requested domain. Exiting..."
			echo
			exit
		fi
	fi
fi

openssl req -new -key $CERTNAME.pem -out $CERTNAME.csr -config ssl.cf

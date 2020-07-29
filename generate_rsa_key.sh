#!/bin/bash

RSABIT=2048

if [ -z $1 ]; then
	echo "[ ERROR ]: Specify site to create key for."
	echo
	echo "[ USAGE ]: $0 www.domain.com"
	echo
	exit
fi

CERTNAME=$1

openssl genrsa -out $CERTNAME.pem $RSABIT

if [ $? -eq 0 ]; then
	openssl rsa -in $CERTNAME.pem -outform PEM -pubout -out $CERTNAME.key
fi
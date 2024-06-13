#!/bin/bash

# detect and remove expired certificates
EXIPRY_DUE=86400

THIS_PROCESS=$BASHPID
shopt -s expand_aliases

if [[ -t 1 ]]; then
	exec 1> >( exec logger --id=${THIS_PROCESS} -s -t "remove_expired.sh" ) 2>&1
	CHILD=$!
else
	exec 1> >( exec logger --id=${THIS_PROCESS} -t "remove_expired.sh" ) 2>&1
	CHILD=$!
fi

declare -x -a CERT_FOLDERS=();

CERT_FOLDERS+=("/var/db/safesquid/ssl/certs/")
CERT_FOLDERS+=("/usr/local/safesquid/security/ssl/")

CA_CRT="/usr/local/safesquid/security/ssl/local/issuer_ca.crt"

IS_CERT()
{
	typeset -i z
	cat $1 | openssl x509 -noout 2> /dev/null
	z=$?
	[[ $z -eq 0 ]] && return $z
	echo "${1} is not an x509 certificate"
	return $z
}

COND_REMOVE()
{
	while read PEM
	do
		/usr/bin/touch -m /var/run/safesquid/cert.check
		IS_CERT ${PEM} || continue;
		cat ${PEM} | openssl x509 -checkend ${EXIPRY_DUE} -noout && continue;
		echo "${PEM} is expired"
		echo "remove PEM: ${PEM}"
		rm -v ${PEM}
	done 
}


MAIN()
{    
	typeset -i i=0
	typeset -i z=${#CERT_FOLDERS[*]}

	/usr/bin/touch -m /var/run/safesquid/cert.check
		
	while [ $i -lt $z ]
	do
		find ${CERT_FOLDERS[$i]} -type f | COND_REMOVE
		(( i++ ))
	done
	
	return;
}


MAIN
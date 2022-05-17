#!/bin/sh

set -e

while IFS= read -r line; do
	TEMPFILE=$(mktemp)
	trap "rm -f $TEMPFILE" INT TERM QUIT
	USER=$(echo $line | awk -F':' '{print $1}')
	FN=$(echo $line | awk -F':' '{print $3}');
	LN=$(echo $line | awk -F':' '{print $4}');
	EMAIL=$(echo $line | awk -F':' '{print $5}');
	if [ -z $USER ]; then
		continue
	fi

	EXTRA_ARGS=""
	if [ ! -z "${FN}" ]; then
		EXTRA_ARGS="${EXTRA_ARGS} --given-name=${FN}"
	fi
	if [ ! -z "${LN}" ]; then
		EXTRA_ARGS="${EXTRA_ARGS} --surname=${LN}"
	fi
	if [ ! -z "${EMAIL}" ]; then
		EXTRA_ARGS="${EXTRA_ARGS} --mail-address=${EMAIL}"
	fi
	# yes, yes this could temporarily show up in the process list, but it should
	# be good enough considering this is an image for testing anyway
	echo $line | awk -F':' '{print $2}' > $TEMPFILE
	samba-tool user create $USER $(cat $TEMPFILE) $EXTRA_ARGS
	rm -f $TEMPFILE
done < "$1"

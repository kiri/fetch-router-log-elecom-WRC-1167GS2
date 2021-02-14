#!/bin/bash
TMPFILE=$(mktemp)
trap 'rm ${TMPFILE}; exit 1' 1 2 3 15

CDIR=$(cd $(dirname $0);pwd)

USER=admin
PASS=YourPassword
URL="http://192.168.2.1/others/system_log.html"

FILE=/var/log/router.log
MAXLINE=10000
KEYWORD='var total_log ='

curl -s -u $USER:$PASS $URL | \
	grep "$KEYWORD" | \
	sed -e 's/^var total_log = "//' -e 's/";$//' -e 's/|syslog|/\n/g' | \
	awk -F'|' '{print $1,$4,$5}' >> ${TMPFILE}

LASTLINE=$(tail -1 ${FILE})
grep "$LASTLINE" $TMPFILE >/dev/null
if [ $? -ne 0 ]; then
	cat ${TMPFILE} >> ${FILE}
else
	cat ${TMPFILE} | grep -A$MAXLINE "$LASTLINE" | tail +2 >> ${FILE}
fi

cat ${FILE} > ${TMPFILE} 
cat ${TMPFILE} | tail -$MAXLINE > ${FILE}

rm ${TMPFILE}

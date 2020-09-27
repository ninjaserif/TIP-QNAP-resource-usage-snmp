#!/bin/bash

# TIP-QNAP-resource-usage-snmp

##### START
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPTDIR

if [ -f "$SCRIPTDIR/config.sh" ]; then
  . config.sh
else
  echo "$SCRIPTDIR/config.sh missing - copy config-sample.sh and update with your own config"
  exit 1
fi

##### Load config
SWVER="~~ TIP-QNAP-resource-usage-snmp version 1.0.0 27/09/2020 ~~"

##### Main
# clear last run
rm -f $SCRIPTDIR/snmp.result

# read in oid list
OID_LIST=`sed -e 's/#.*//' $SCRIPTDIR/oid.list | sed -e ':a;N;$!ba;s/\n//g'`

# call snmpget for IP and OID list and save to snmp.result
snmpget -Ov -OQ -Ot -OS -c $COMMUNITY -v2c $HOST_IP $OID_LIST > $SCRIPTDIR/snmp.result

# cleanup snmp.result and put into array
sed -i -e 's/[ ].*//' -e 's/"//g' $SCRIPTDIR/snmp.result
mapfile -t snmparray < $SCRIPTDIR/snmp.result

# read oid.list into array to get element names
mapfile -t oidarray < $SCRIPTDIR/oid.list
for i in ${!oidarray[@]}; do
  oidarray[i]=`echo ${oidarray[i]} | sed -n -e 's/^.*#//p'`
done

# loop through array and build json
jsonout="{\"hostname\":\""$HOST_NAME"\""
for i in "${!snmparray[@]}"
do
  jsonout+=`echo , \""${oidarray[i]}"\":${snmparray[i]}`
done
jsonout+="}"

echo -e "$jsonout"

##### END
#!/bin/bash
#Author Priyanka Dive,Pravin Magdum
#Email priyanka.dive@crevise.com,pravin.magdum@crevise.com
echo "Script to send pm2 status to Prometheus"
while true
do

pm2 list | grep "app.keymetrics.io"

if [ "$?" == 0 ]
then
linecount=5;
else
linecount=4;
fi

echo $linecount

pm2 list|head -n-2|tail -n+$linecount|awk  '{ print $2"_restart_count" "\t" $12 "\n" $2"_CPU_Usage" "\t" substr($16,1,  length($16)-1) "\n" $2"_MEMORY_Usage" "\t" $18 }'|sed 's/-/_/g' > /home/srkay/monitor/Metrics/pm2_Merics.prom
sleep 10s
done
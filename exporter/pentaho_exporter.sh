#!/bin/bash
#Author Priyanka Dive,Pravin Magdum
#Email priyanka.dive@crevise.com,pravin.magdum@crevise.com
echo "Custom exporter for process $1"
while true
do
echo "Process Memory Usage"
Prometheus_ID=`ps -ef|grep java|grep $1|grep -v 'grep'|grep -v 'pentaho_exporter'|awk '{print $2}'`
echo $Prometheus_ID
Prometheus_MEMORY_Value=`top -b -n 1|grep $Prometheus_ID |awk '{print $10}'`
Prometheus_MEMORY_Value=${Prometheus_MEMORY_Value%.*}
#echo $Prometheus_MEMORY_Value
Process_Name=`echo $1|sed 's/-/_/g'`
Process_Name=`echo "Pentaho_"$Process_Name`
#echo $Process_Name

#echo "Process Status"
Prometheus_STATUS=`ps -p $Prometheus_ID|echo $?`
#echo $Prometheus_STATUS

#echo "Process CPU Usage"
Prometheus_CPU_Value=`top -b -n 1|grep $Prometheus_ID |awk '{print $9}'`
Prometheus_CPU_Value=${Prometheus_CPU_Value%.*}
#echo "$Prometheus_CPU_Value"

#[ "$1" == "" ] && echo "Error: Missing PID" && exit 1
IO=/proc/$Prometheus_ID/io          # io data of PID
[ ! -e "$IO" ] && echo "Error: PID does not exist" && exit 2

#echo "Watching command $(cat /proc/$1/comm) with PID $1"

IFS=" " read rchar wchar syscr syscw rbytes wbytes cwbytes < <(cut -d " " -f2 $IO | tr "\n" " ")
sleep 3s
 while [ -e $IO ]; do
    IFS=" " read rchart wchart syscrt syscwt rbytest wbytest cwbytest < <(cut -d " " -f2 $IO | tr "\n" " ")
Prometheus_DISK_READ=$((($rchart-$rchar)+($rbytest-$rbytes)))
#echo $Prometheus_DISK_READ
Prometheus_DISK_WRITE=$((($wchart-$wchar)+($wbytest-$wbytes)))
#echo $Prometheus_DISK_WRITE
break
done
echo ""$Process_Name"_MEMORY_Usage "$Prometheus_MEMORY_Value"
"$Process_Name"_CPU_Usage "$Prometheus_CPU_Value"
"$Process_Name"_DISK_READ "$Prometheus_DISK_READ"
"$Process_Name"_DISK_WRITE "$Prometheus_DISK_WRITE"
"$Process_Name"_STATUS "$Prometheus_STATUS"" > /home/srkay/monitor/Metrics/"$Process_Name"_Metrics_Value.prom
sleep 5s
done
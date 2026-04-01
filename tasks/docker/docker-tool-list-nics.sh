#!/bin/bash
export containers=$(sudo docker ps --format "{{.ID}}|{{.Names}}")
export interfaces=$(sudo ip ad);

export minColWidth=("06" "15" "30" "10")
export col0=$(printf "%${minColWidth[0]}s" "ContainerId")
export col1=$(printf "%${minColWidth[1]}s" "# of interface")
export col2=$(printf "%${minColWidth[2]}s" "Interface Name")
export col3=$(printf "%${minColWidth[3]}s" "Container Name")

echo -e "$col0\t$col1\t$col2\t$col3"
echo -e "-------------|---------------------------------|--------------|-----------------"
for x in $containers
        do
                export name=$(echo "$x" |cut -d '|' -f 2);
                export id=$(echo "$x"|cut -d '|' -f 1)

                export ifaceNum="$(echo $(sudo docker exec -it "$id" cat /sys/class/net/eth0/iflink) | sed s/[^0-9]*//g):"
                export ifaceNum=$(echo $ifaceNum | sed 's/://')
                export paddedIfaceNum=$(printf %06s $ifaceNum)

                export ifaceStr=$(echo "$interfaces" | grep "^$ifaceNum" | cut -d ':' -f 2 | cut -d '@' -f 1);
                export paddedIfaceStr=$(printf %36s $ifaceStr)

                echo -e "$id\t$paddedIfaceNum\t${paddedIfaceStr::-1}\t$name";
done
#!/bin/sh

source /etc/profile
hfile=/usr/local/haproxy/haproxy.cfg
wip=$(/usr/bin/dig +short sql.hiredin.cn @119.29.29.29 | /usr/bin/grep -P '\d')
hip=$(/usr/bin/awk '/src/{print $4}' /usr/local/haproxy/haproxy.cfg|head -1)


changeip(){
    /usr/bin/echo "wip" $wip "hip" $hip
    if [ "$wip" = "" ];then
        exit 100
    fi

    if [ "$hip" = "" ];then
        echo "hip is kong"
        hip=1.1.1.1
        /usr/bin/sed -r -i 's/src\s+[0-9 .]*/src 1.1.1.1/' $hfile
    fi

    if [ $wip = $hip ];then
        exit 101
    else
        /usr/bin/sed -i "s/$hip/$wip/g" $hfile
        /usr/bin/echo $(date) haproxy restart wip:$wip hip:$hip >> /root/harestart.log
    fi
}

changehd2(){
    if grep 106.14.27.146 $hfile;then
        exit
    fi
    /usr/bin/sed -r -i 's/acl jkmOnline_allowed src.*/& 106.14.27.146/' $hfile
    /usr/bin/sed -r -i 's/acl jkOnline_allowed src.*/& 106.14.27.146/' $hfile
}

restarthaproxy(){
    /usr/bin/kill -9 $(/usr/sbin/pidof haproxy)
#    /usr/bin/pkill haproxy
    sleep 1
    /usr/sbin/haproxy -f $hfile
}

if [ $wip = $hip ];then
        exit
else
    changeip && restarthaproxy
    changehd2 && restarthaproxy
#    source  /root/RestartHaproxy.sh
#    /usr/bin/kill -9 $(/usr/sbin/pidof haproxy)
#    /usr/sbin/haproxy -f $hfile
#    /usr/bin/pkill haproxy && /usr/sbin/haproxy -f /usr/local/haproxy/haproxy.cfg
fi

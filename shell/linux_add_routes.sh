#!/bin/bash

####################################################################

ip_route_helper() {
    net1='100.64.0.0/10'

    gw=$(ip r get 10.0.0.0 | awk '/via/ {print $3}')

    [[ -z "$gw" ]] && error "Error: the default gw: [$gw] is empty"

    route_entry_1="$net1 via $gw dev eth0"

    if ! ip route | grep -q "$net1" ; then
        ip route add $route_entry_1 || error "Error: failed to add $route_entry_1"
    fi
}

change_redhat_routes() {
    route_conf_file=/etc/sysconfig/network-scripts/route-eth0
    [[ -f $route_conf_file ]] && cp $route_conf_file ${route_conf_file}.original

    ip_route_helper

    route_entry_1="$net1 via $gw dev eth0"

    if ! grep -q "100\.64\.0\.0" $route_conf_file >& /dev/null; then
        echo "$route_entry_1" >> $route_conf_file
    fi
}

change_ubuntu_routes() {
    route_conf_file=/etc/network/interfaces
    [[ -f $route_conf_file ]] && cp $route_conf_file ${route_conf_file}.original

    ip_route_helper

    route_entry_1="up route add -net 100.64.0.0 netmask 255.192.0.0 gw $gw dev eth0"

    if ! grep -q "100\.64\.0\.0" $route_conf_file >& /dev/null ; then
        echo "$route_entry_1" >>  $route_conf_file
    fi
}

change_suse_routes() {
    route_conf_file=/etc/sysconfig/network/ifroute-eth0
    [[ -f $route_conf_file ]] && cp $route_conf_file ${route_conf_file}.original

    ip_route_helper

    route_entry_1="100.64.0.0 $gw 10 eth0"

    if ! grep -q "100\.64\.0\.0" $route_conf_file >& /dev/null; then
        echo "$route_entry_1" >>  $route_conf_file
    fi
}

change_gentoo_routes() {
    route_conf_file=/etc/conf.d/net
    [[ -f $route_conf_file ]] && cp $route_conf_file ${route_conf_file}.original
    gw=$(route -n | awk '/^0.0.0.0/ {print $2}')

    if ! route -n | grep -q '100\.64\.0\.0' ; then
        route add -net 100.64.0.0/10 gw $gw eth0 || error "Error: failed to add 100.64.0.0/10"
    fi

    if ! grep -q 'routes_eth0' $route_conf_file >& /dev/null; then
        echo "routes_eth0=(\"100.64.0.0/10 via $gw\")" >> $route_conf_file
    else
        if ! grep -q '100\.64\.0\.0' $route_conf_file >& /dev/null; then
            sed -i "s#\(routes_eth0=.*\))#\1 \"100.64.0.0/10 via $gw\"\)#" $route_conf_file
        fi
    fi
}

change_coreos_routes() {
    route_conf_file=/etc/systemd/network/10-eth0.network
    [[ -f $route_conf_file ]] && cp $route_conf_file ${route_conf_file}.original

	ip_route_helper

    if ! grep -q '100.64.0.0' $route_conf_file >& /dev/null; then
    cat >> $route_conf_file << EOF
[Route]
Destination=100.64.0.0/10
Gateway=$gw
EOF
    fi
}

####################################################################

error() {
    echo $1
    exit 1
}

change_routes() {

    result=$(egrep -o 'Ubuntu|Red Hat|SUSE|Debian|Gentoo|Gentoo Hardened|AliCloud' /proc/version | uniq | head -n 1)
    case $result in
        'Ubuntu' | 'Debian')
			change_ubuntu_routes
			;;
		'Red Hat' | 'AliCloud')
			change_redhat_routes
			;;
		'SUSE')
			change_suse_routes
			;;
		'Gentoo')
			change_gentoo_routes
			;;
		'Gentoo Hardened')
			change_coreos_routes
			;;
		*)
			error "Error: unknow platform: [$result]"
			;;
	esac
    echo 'add route 100.64.0.0/10 success !'
}

change_routes

####################################################################


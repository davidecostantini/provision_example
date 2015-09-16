#!/bin/sh

#Params
#Hostname
#Role
#Puppet master server

if [ "$1" = "" ]; then
	echo "Please specify the new local hostname as first param!"
	exit 1
fi

if [ "$2" = "" ]; then
	echo "Please specify the role [master,agent] as 2nd param!"
	exit 1
fi

if [ "$3" = "" ]; then
	echo "Please specify the puppetmaster as 3rd param!"
	exit 1
fi

instance_hostname=$1 
role=$2
puppetmaster=$3

local_ip=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
hostname $instance_hostname
domain=$(hostname --fqdn)
fqnd="$instance_hostname.$domain"
#
# Changing hostname for puppet
#
echo "$instance_hostname" > /etc/hostname
echo "$local_ip $fqnd $instance_hostname"
echo "The hostname is now $instance_hostname"

#RHEL 6
#yum update -y
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

if [ "$role" = "master" ]; then
	yum install -y puppet-server
	
	puppet module install jfryman-selinux
	puppet module install puppetlabs-firewall
	puppet module install puppetlabs-apache
	puppet module install jfryman-nginx
	puppet module install puppetlabs-haproxy
	puppet module install aptituz-ssh
	puppet module install puppetlabs-lvm
	puppet module install derdanne-nfs
	puppet module install jgreat-docker
	puppet module install evenup-beaver
	puppet module install puppetlabs-apt
	puppet module install datadog-datadog_agent
	puppet module install puppetlabs-vcsrepo
	puppet module install elasticsearch-elasticsearch
	puppet module install elasticsearch-logstash
	puppet module install camptocamp-kibana
	puppet module install wdijkerman-zabbix
	puppet module install camptocamp-openssl
	puppet module install thias-openvpn
	puppet module install rtyler-jenkins
	puppet module install haraldsk-nfs

	#Adding autosign
	echo "[master]" >> /etc/puppet/puppet.conf
    echo "autosign = true" >> /etc/puppet/puppet.conf

	#Autosign
	echo "*.cloud.infomentum.co.uk" > /etc/puppet/autosign.conf
	echo "*.local" >> /etc/puppet/autosign.conf

	cp site.pp /etc/puppet/manifests/

	service puppetmaster restart

elif [ "$role" = "agent" ]; then
	yum install -y puppet
	puppet agent --server $puppetmaster --waitforcert 60 --test
	
	cp agent.conf /etc/puppet/puppet.conf

	echo "server = $puppetmaster" >> /etc/puppet/puppet.conf
	echo "runinterval = 20" >> /etc/puppet/puppet.conf

	service puppet restart

else
	echo "No role found for $role"
	exit 1
fi
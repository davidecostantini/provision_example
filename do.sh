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
	#yum install -y http://yum.theforeman.org/releases/1.9/el6/x86_64/foreman-release.rpm

	#yum install -y foreman-installer
	#foreman-installer -v

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
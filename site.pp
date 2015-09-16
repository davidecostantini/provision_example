###Variables
$subnet = "192.168.1.0/24"

###Classes
class common_class {

	class { 'selinux':
	 mode => 'disabled'
	}

	resources { 'firewall':
	  purge => true
	}

	firewall { '000 accept all requests':
	  proto  => 'all',
	  action => 'accept'
	}

	include nfs::client
	Nfs::Client::Mount <<| |>> {
		ensure => 'mounted'
	}	
}

##Roles
class role_webserver {
	include common_class 
}

class role_jenkins {
	include common_class 
	include jenkins
}

class role_jenkins {
	include common_class 
	include nfs::server

	file { "/data_folder":
	    ensure => "directory",
	}

	nfs::server::export{ '/data_folder':
	ensure  => 'mounted',
	clients => "${subnet}(rw,insecure,async,no_root_squash) localhost(rw)"
	require	=> File['/data_folder']
}

###Start
node 'jenkins.example.com' {
	include role_jenkins
}

node 'nfserver.example.com' {
	include role_nfsserver
}

node default {
	include role_jenkins
}
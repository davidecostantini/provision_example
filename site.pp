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
}

##Roles
class role_webserver {
	include common_class 
}

class role_jenkins {
	include common_class 
	include jenkins
}


###Start
node 'www1.example.com' {
	include role_jenkins
}
file { "/tmp/dave":
    ensure => "present",
    owner  => "root",
    content => "default content set by puppet master",
    mode   => 750,
}

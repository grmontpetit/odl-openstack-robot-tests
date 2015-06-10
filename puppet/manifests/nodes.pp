node basenode {

  $base_packages = [
    "kernel-headers",
    "kernel-devel",
    "gcc",
    "make",
    "python-devel",
    "openssl-devel",
    "kernel-devel",
    "graphviz",
    "kernel-debug-devel",
    "automake",
    "rpm-build",
    "redhat-rpm-config",
    "libtool git",
    "git"
  ]

  package { $base_packages:
    ensure => installed,
  }
}

node ovsnode inherits basenode {

  package { "mininet":
    ensure => installed,
    require => [
                  Package["ovs_switch"],
               ]
  }

    file { "/root/rpmbuild/SOURCES"
    ensure => diretory,
  }

  exec { "download_ovs":
    command => "/usr/bin/wget http://openvswitch.org/releases/openvswitch-2.3.1.tar.gz -O /root/openvswitch-2.3.1.tar.gz",
    cwd     => "/root",
    creates => "/root/openvswitch-2.3.1.tar.gz",
  }

  exec { "copy_archive":
    command => "cp openvswitch-2.3.1.tar.gz /root/rpmbuild/SOURCES/",
    cwd     => "/root",
    require => [
                  Exec["download_ovs"],
               ],
    creates => "/root/rpmbuild/SOURCES/README",
  }

  exec { "extract_ovs":
    command => "tar xvfz openvswitch-2.3.1.tar.gz -C /root/rpmbuild/SOURCES --strip-components=1",
    cwd     => "/root",
    require => [
                  Exec["download_ovs"],
               ],
    creates => "/root/rpmbuild/SOURCES/README",
  }
}

node controllernode inherits basenode {
  
}

node robotnode inherits basenode {
  
}

import 'nodes/*.pp'

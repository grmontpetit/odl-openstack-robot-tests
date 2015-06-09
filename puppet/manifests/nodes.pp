node basenode {
    exec { "install-prereq"
  sudo cd /root/
  sudo wget http://openvswitch.org/releases/openvswitch-2.3.1.tar.gz -O /root/openvswitch-2.3.1.tar.gz
  sudo mkdir -p /root/rpmbuild/SOURCES
  sudo cp openvswitch-2.3.1.tar.gz /root/rpmbuild/SOURCES/
  sudo rpmbuild -bb rhel/openvswitch.spec
  sudo rpmbuild -bb rhel/openvswitch-kmod-rhel7.spec
  sudo rpm -ivh /root/rpmbuild/RPMS/*.rpm
    }

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
    "rpm-build",
    "openssl-devel"
  ]

  package { $base_packages:
    ensure => installed,
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

  exec { "build_ovs":
    command     => "rpmbuild -bb rhel/openvswitch.spec",
    cwd         => "/root/rpmbuild/SOURCES/ovs",
    logoutput   => true,
    loglevel    => verbose,
    timeout     => 0,
    creates     => "/root/openvswitch-common_2.3.0-1_amd64.deb",
    require     => [
                     Package[$base_packages],
                     Exec["extract_ovs"],
                   ],
  }

    exec { "build_ovs":
    command     => "rpmbuild -bb rhel/openvswitch-kmod-rhel6.spec",
    cwd         => "/root/rpmbuild/SOURCES/ovs",
    logoutput   => true,
    loglevel    => verbose,
    timeout     => 0,
    creates     => "/root/openvswitch-common_2.3.0-1_amd64.deb",
    require     => [
                     Package[$base_packages],
                     Exec["extract_ovs"],
                   ],
  }

}

  $base_packages = [
    "kernel-headers",
    "kernel-devel",
    "gcc",
    "make",
    "python-devel",
    "openssl-devel",
    "graphviz",
    "kernel-debug-devel",
    "automake",
    "rpm-build",
    "redhat-rpm-config",
    "libtool git",
    "git"
  ]

  notice("specified ovs version to install: ${ovsversion}")

  package { $base_packages:
    ensure => installed,
  }

  file { "/root/rpmbuild/SOURCES/":
    ensure => diretory,
  }

  exec { "download_ovs":
    command => "/usr/bin/wget http://openvswitch.org/releases/openvswitch-${ovsversion}.tar.gz",
    cwd     => "/root",
    creates => "/root/openvswitch-${ovsversion}.tar.gz",
    path    => "/root",
  }

  exec { "copy_archive":
    command => "/bin/cp openvswitch-${ovsversion}.tar.gz rpmbuild/SOURCES/",
    cwd     => "/root",
    require => [
                  Exec["download_ovs"],
               ],
    path    => "/root",
    creates => "/root/rpmbuild/SOURCES/openvswitch-${ovsversion}.tar.gz",
  }

  exec { "extract_ovs":
    command => "tar xvfz openvswitch-${ovsversion}.tar.gz -C openvswitch-${ovsversion}",
    cwd     => "/root",
    require => [
                  Exec["copy_archive"],
               ],
    path => "/root",
    creates => "/root/openvswitch-${ovsversion}/README",
  }

  exec { "custom_sed":
    command => "sed 's/openvswitch-kmod, //g' openvswitch-${ovsversion}/rhel/openvswitch.spec > openvswitch-${ovsversion}/rhel/openvswitch_no_kmod.spec",
    cwd     => "/root",
    require => [
                  Exec["extract_ovs"],
               ],
    path => "/root",
  }

  exec { "build_ovs":
    command => "rpmbuild -bb --nocheck openvswitch-${ovsversion}/rhel/openvswitch_no_kmod.spec",
    cwd     => "/root",
    require => [
                  Exec["custom_sed"],
               ],
    path => "/root",
    creates => "/root/rpmbuild/RPMS/x86_64/openvswitch-${ovsversion}-1.x86_64.rpm",
  }

    exec { "install_ovs":
    command => "yum localinstall rpmbuild/RPMS/x86_64/openvswitch-${ovsversion}-1.x86_64.rpm",
    cwd     => "/root",
    path => "/root",
    require => [
                  Exec["build_ovs"],
               ],
  }

  exec { "start_ovs":
    command => "systemctl start openvswitch.service",
    cwd     => "/root",
    require => [
                  Exec["install_ovs"],
               ],
    path => "/root",
  }

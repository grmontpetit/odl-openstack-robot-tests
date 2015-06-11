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

  file { [
           "/root/rpmbuild/",
           "/root/rpmbuild/SOURCES/",
         ]:
    ensure => directory,
  }

  exec { "download_ovs":
    command => "wget http://openvswitch.org/releases/openvswitch-${ovsversion}.tar.gz",
    cwd     => "/usr/bin",
    creates => "/root/openvswitch-${ovsversion}.tar.gz",
    path    => "/root",
  }

  exec { "copy_archive":
    command => "cp openvswitch-${ovsversion}.tar.gz rpmbuild/SOURCES/openvswitch-${ovsversion}.tar.gz",
    cwd     => "/bin",
    require => [
                  Exec["download_ovs"],
               ],
    path    => "/root",
    creates => "/root/rpmbuild/SOURCES/openvswitch-${ovsversion}.tar.gz",
  }

  exec { "extract_ovs":
    command => "/bin/tar xvfz /root/openvswitch-${ovsversion}.tar.gz -C /root/",
    cwd     => "/usr/bin",
    require => [
                  Exec["copy_archive"],
               ],
    path => "/root",
    creates => "/root/openvswitch-${ovsversion}/README",
  }

  exec { "custom_sed":
    command => "/usr/bin/sed 's/openvswitch-kmod, //g' openvswitch-${ovsversion}/rhel/openvswitch.spec > openvswitch-${ovsversion}/rhel/openvswitch_no_kmod.spec",
    cwd     => "/usr/bin",
    require => [
                  Exec["extract_ovs"],
               ],
    path => "/root",
  }

  exec { "build_ovs":
    command => "/usr/bin/rpmbuild -bb --nocheck openvswitch-${ovsversion}/rhel/openvswitch_no_kmod.spec",
    cwd     => "/root",
    require => [
                  Exec["custom_sed"],
               ],
    path => "/root",
    creates => "/root/rpmbuild/RPMS/x86_64/openvswitch-${ovsversion}-1.x86_64.rpm",
  }

    exec { "install_ovs":
    command => "yum localinstall rpmbuild/RPMS/x86_64/openvswitch-${ovsversion}-1.x86_64.rpm",
    cwd     => "/usr/bin",
    path => "/root",
    require => [
                  Exec["build_ovs"],
               ],
  }

  exec { "start_ovs":
    command => "systemctl start openvswitch.service",
    cwd     => "/usr/bin",
    require => [
                  Exec["install_ovs"],
               ],
    path => "/root",
  }

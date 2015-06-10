node ovs2 {

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

  file { "/root/rpmbuild/SOURCES":
    ensure => diretory,
  }

  exec { "download_ovs":
    command => "/usr/bin/wget http://openvswitch.org/releases/openvswitch-${ovsversion}.tar.gz -O /root/openvswitch-${ovsversion}.tar.gz",
    cwd     => "/root",
    creates => "/root/openvswitch-${ovsversion}.tar.gz",
  }

  exec { "copy_archive":
    command => "cp openvswitch-${ovsversion}.tar.gz /root/rpmbuild/SOURCES/",
    cwd     => "/root",
    require => [
                  Exec["download_ovs"],
               ],
    creates => "/root/rpmbuild/SOURCES/README",
  }

  exec { "extract_ovs":
    command => "tar xvfz openvswitch-${ovsversion}.tar.gz",
    cwd     => "/root",
    require => [
                  Exec["copy_archive"],
               ],
    creates => "/root/rpmbuild/SOURCES/README",
  }

  exec { "custom_sed":
    command => "sed 's/openvswitch-kmod, //g' openvswitch-${ovsversion}/rhel/openvswitch.spec > openvswitch-${ovsversion}/rhel/openvswitch_no_kmod.spec",
    cwd     => "/root",
    require => [
                  Exec["extract_ovs"],
               ],
  }

  exec { "build_ovs":
    command => "rpmbuild -bb --nocheck openvswitch-${ovsversion}/rhel/openvswitch_no_kmod.spec",
    cwd     => "/root",
    require => [
                  Exec["custom_sed"],
               ],
    creates => "/root/rpmbuild/RPMS/x86_64/openvswitch-${ovsversion}-1.x86_64.rpm",
  }

    exec { "install_ovs":
    command => "yum localinstall ~/rpmbuild/RPMS/x86_64/openvswitch-${ovsversion}-1.x86_64.rpm",
    cwd     => "/root",
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
  }


}
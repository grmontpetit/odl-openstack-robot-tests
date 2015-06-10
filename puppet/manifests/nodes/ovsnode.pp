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
    command => "tar xvfz openvswitch-2.3.1.tar.gz",
    cwd     => "/root",
    require => [
                  Exec["copy_archive"],
               ],
    creates => "/root/rpmbuild/SOURCES/README",
  }

  exec { "custom_sed"
    command => "sed 's/openvswitch-kmod, //g' openvswitch-2.3.1/rhel/openvswitch.spec > openvswitch-2.3.1/rhel/openvswitch_no_kmod.spec",
    cwd     => "/root"
    require => [
                  Exec["extract_ovs"],
               ]
  }

  exec { "build_ovs"
    command => "rpmbuild -bb --nocheck openvswitch-2.3.1/rhel/openvswitch_no_kmod.spec"
    cwd     => "/root"
    require => [
                  Exec["custom_sed"],
               ]
    creates => "/root/rpmbuild/RPMS/x86_64/openvswitch-2.3.1-1.x86_64.rpm"
  }

    exec { "install_ovs"
    command => "yum localinstall ~/rpmbuild/RPMS/x86_64/openvswitch-2.3.1-1.x86_64.rpm"
    cwd     => "/root"
    require => [
                  Exec["build_ovs"],
               ]
  }

  exec { "start_ovs"
    command => "systemctl start openvswitch.service"
    cwd     => "/root"
    require => [
                  Exec["install_ovs"],
               ]
  }
}
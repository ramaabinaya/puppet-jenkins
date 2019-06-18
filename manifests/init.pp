# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include jenkins
class jenkins {

# create a zenuser user and a group for generel use
  group { 'zenuser':
    ensure => 'present',
    gid    => '642',
  }

  user { 'zenuser':
    ensure           => 'present',
    gid              => '642',
    comment          => 'Zen Automation User',
    # groups           => 'zenuser',
    password         => '!!',
    password_max_age => '99999',
    password_min_age => '0',
    shell            => '/bin/bash',
    uid              => '642',
  }

  class { 'docker':
    docker_users => ['ubuntu', 'zenuser'],
  }

  include jenkins::install
  include jenkins::apache

}

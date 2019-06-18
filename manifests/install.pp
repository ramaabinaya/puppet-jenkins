# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include jenkins::install
class jenkins::install {

  File {
    owner  => 'zenuser',
    group  => 'zenuser',
    mode   => '0755',
  }

  file { ['/opt/zenjenkins', '/opt/zenjenkins/config', '/opt/zenjenkins/plugins', '/opt/zenjenkins/data'] :
    ensure => 'directory'
  }

  file { '/opt/zenjenkins/Dockerfile' :
    ensure  => file,
    content => template('jenkins/opt/zenjenkins/Dockerfile.erb')
  }

  file { '/opt/zenjenkins/config/config.xml' :
    ensure  => file,
    content => template('jenkins/opt/zenjenkins/config/config.xml.erb')
  }

  file { '/opt/zenjenkins/config/com.michelin.cio.hudson.plugins.maskpasswords.MaskPasswordsConfig.xml' :
    ensure  => file,
    content => template('jenkins/opt/zenjenkins/config/com.michelin.cio.hudson.plugins.maskpasswords.MaskPasswordsConfig.xml.erb')
  }

  file { '/opt/zenjenkins/config/jenkins.model.JenkinsLocationConfiguration.xml' :
    ensure  => file,
    content => template('jenkins/opt/zenjenkins/config/jenkins.model.JenkinsLocationConfiguration.xml.erb')
  }

  file { '/opt/zenjenkins/plugins/plugins.txt' :
    ensure  => file,
    content => template('jenkins/opt/zenjenkins/plugins/plugins.txt.erb')
  }

  file { '/opt/zenjenkins/docker-compose.yaml' :
    ensure  => file,
    content => template('jenkins/opt/zenjenkins/docker-compose.yaml.erb')
  }

  docker::image { 'jenkins/jenkins':
    image_tag => '2.164.3-alpine'
  }

  docker::image { 'zenjenkins' :
    docker_file => '/opt/zenjenkins/Dockerfile',
    docker_dir  => '/opt/zenjenkins'
  }

  class {'docker::compose':
    ensure  => present,
    version => '1.23.2',
  }

  docker_compose { 'centizen_jenkins' :
    ensure        => present,
    compose_files => ['/opt/zenjenkins/docker-compose.yaml'],
  }

}

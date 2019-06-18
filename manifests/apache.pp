# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include jenkins::apache
# class { 'jenkins::apache' : enable_ssl     => true, ssl_cert_file  => '/etc/apache2/ssl/apache.crt', ssl_key_file   => '/etc/apache2/ssl/private/apache.key',}
class jenkins::apache (
  $enable_ssl    = false,
  $ssl_cert_file = undef,
  $ssl_key_file  = undef
  )
{

  class { 'apache' :
    default_vhost     => false,
    default_ssl_vhost => false,
  }

  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::ssl
  include apache::mod::headers

  $logformat = '%h %D %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"'
  $certname  = 'jenkins.centizenapps.com'
  $http_rewrites = $enable_ssl ? {
    true => [ { rewrite_cond => '%{HTTPS} !=on', rewrite_rule => '^/(.*) https://%{SERVER_NAME}/$1 [NE,R,L]', }, ],
    default => undef
    }

  apache::vhost { 'http-jenkins' :
    port                => '80',
    docroot             => '/var/www/html',
    docroot_owner       => 'www-data',
    docroot_group       => 'www-data',
    access_log_format   => $logformat,
    access_log_file     => 'jenkins-access.log',
    error_log           => true,
    error_log_file      => 'jenkins-error.log',
    servername          => $certname,
    proxy_preserve_host => 'on',
    rewrites            => $http_rewrites,
    proxy_pass          => {
                  path => '/',
                  url  => 'http://localhost:8080/'
                  }
  }

  if $enable_ssl {
    apache::vhost { 'ssl-jenkins' :
      port                => 443,
      ssl                 => true,
      access_log_format   => $logformat,
      access_log_file     => 'ssl-jenkins-access.log',
      error_log           => true,
      error_log_file      => 'ssl-jenkins-error.log',
      ssl_cert            => $ssl_cert_file,
      ssl_key             => $ssl_key_file,
      docroot             => '/var/www/html',
      docroot_owner       => 'www-data',
      docroot_group       => 'www-data',
      servername          => $certname,
      ssl_protocol        => 'All -SSLv2 -SSLv3',
      proxy_preserve_host => 'on',
      proxy_pass          => {
                    path => '/',
                    url  => 'http://localhost:8080/'
                    },
    }
  }
}

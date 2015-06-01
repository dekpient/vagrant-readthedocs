# Define: database
# Parameters:
# $dir
# $user
# $path
# $admin
# $email
# $password
#
define rtd::database (
  $dir      = undef,
  $clean    = false,
  $user     = 'vagrant',
  $path     = undef,
  $admin    = 'admin',
  $email    = 'admin@localhost',
  $password = 'b',
) {

  Exec {
    cwd  => $dir,
    path => $path,
    user => $user,
  }

  exec { 'resetdb' :
    command => 'python manage.py reset_db --noinput',
    onlyif  => "$clean && /usr/bin/test -e $dir/../dev.db",
  } ->

  exec { 'syncdb' :
    command => 'python manage.py syncdb --noinput',
    onlyif  => "test ! -e $dir/../dev.db",
  }

  exec { 'migrate' :
    command     => 'python manage.py migrate',
    subscribe   => Exec['syncdb'],
    refreshonly => true,
  }

  exec { 'testdata' :
    command     => 'python manage.py loaddata test_data',
    subscribe   => Exec['migrate'],
    refreshonly => true,
  }

  exec { 'admin' :
    command     => "echo \"from django.contrib.auth.models import User; User.objects.create_superuser('$admin', '$email', '$password')\" | python manage.py shell",
    subscribe   => Exec['migrate'],
    refreshonly => true,
  }

  exec { 'verify-mail' :
    command     => "echo \"insert into account_emailaddress values(2, (select id from auth_user where username = '$admin'), (select email from auth_user where username = '$admin'), 1, 1);\" | python manage.py dbshell",
    subscribe   => Exec['admin'],
    refreshonly => true,
  }

}

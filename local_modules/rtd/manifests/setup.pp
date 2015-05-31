# Define: setup
# Parameters:
# $dir
# $user
# $path
# $admin
# $email
# $password
#
define rtd::setup (
  $dir      = undef,
  $user     = 'vagrant',
  $path     = undef,
  $admin    = 'admin',
  $email    = 'admin@localhost',
  $password = 'b',
) {

  Exec {
    cwd     => $dir,
    path    => $path,
    user    => $user,
  }

  exec { 'syncdb' :
    command => 'python manage.py syncdb --noinput',
  } ->

  exec { 'migrate' :
    command => 'python manage.py migrate',
  } ->

  exec { 'testdata' :
    command => 'python manage.py loaddata test_data',
  } ->

  exec { 'admin' :
    command => "echo \"from django.contrib.auth.models import User; User.objects.create_superuser('$admin', '$email', '$password')\" | python manage.py shell",
  } ->

  exec { 'verify-mail' :
    command => "echo \"insert into account_emailaddress values(2, (select id from auth_user where username = '$admin'), (select email from auth_user where username = '$admin'), 1, 1);\" | python manage.py dbshell",
  }

}

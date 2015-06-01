## Read the Docs on Centos 7
###### quick and dirty via Vagrant and Puppet

### Requires
- `librarian-puppet`
- `vagrant plugin install vagrant-librarian-puppet` (actually, it's optional - *meh*)

### `vagrant up` Then What?
- Open `localhost:8000` and log in with `admin` password `b`
- Open `localhost:9001` for Supervisor web interface. You can restart RTD and tail the log there.

### Notes
- Installing Read the Docs's requirements takes a while - \*staring at\* `Python::Requirements`
- Read the Docs is run as `vagrant` user

### What Else?
Explore `puppet/manifests/init.pp`.

#### Reset Database
Set `$reset_db` to `true`, then run `vagrant provision`. Don't forget to change it back.

#### Private Repo
RTD has `ALLOW_PRIVATE_REPO = True`. If you want an ssh key generated, set `$ssh` to `true`, and you'll get a public key for `vagrant` user: `id_rsa.pub`. Setting `$connect_host` and `$connect_port` ensures that you don't get host verification prompt.

### TODO
- Address `WARNING [elasticsearch:82] ... ProtocolError: ('Connection aborted.', error(111, 'Connection refused'))`
## Read the Docs on Centos 7
#### quick and dirty via Vagrant and Puppet

### Requires
- `librarian-puppet`
- `vagrant plugin install vagrant-librarian-puppet` (actually, it's optional - *meh*)

### `vagrant up` Then What?
- Go to `localhost:8088` and log in with `admin` password `b`
- Go to `localhost:9001` for Supervisor web interface
- You get a public key for `vagrant` user: `id_rsa.pub`

### Notes
- Installing Read the Docs's requirements takes a while - \*staring at\* `Python::Requirements`
- Read the Docs is run as `vagrant` user
- RTD has `ALLOW_PRIVATE_REPO = True`

### Reset Database
Look for `rtd::database` in `init.pp` and set `clean => true`, then run `vagrant provision`. Don't forget to change it back.

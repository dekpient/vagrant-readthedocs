## Read the Docs on Centos 7
#### quick and dirty via Vagrant and Puppet

### Requires
- `librarian-puppet`
- `vagrant plugin install vagrant-librarian-puppet` (actually, it's optional - *meh*)

### `vagrant up` Then What?
- Go to `localhost:8088` and log in with `admin` password `b`
- Go to `localhost:9001` for Supervisor web interface
- You get a public key for `vagrant` user: `id_rsa.pub`

#### Notes
- If you see `Warning: Firewall[010 accept tcp access](provider=iptables): Unable to persist firewall rules: Execution of '/usr/libexec/iptables/iptables.init save' returned 1:`, look for `Notice: /Stage[main]/Main/Firewall[010 accept tcp access]/ensure: created` first. Don't know why - don't care enough.
- Installing Read the Docs's requirements takes a while - \*staring at\* `Python::Requirements`
- Read the Docs is run as `vagrant` user

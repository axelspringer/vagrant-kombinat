# coreos-kombinat

What we provide here, is Kombinat (our flavor of Mesos) in a box. We use [CoreOS](https://coreos.com/) and [Docker Swarm](https://docs.docker.com/engine/swarm/) to run [Apache Mesos](http://mesos.apache.org/) with some additions on top. 

:smirk: Sounds crazy? Because, that it is. Though, [Docker Swarm](https://docs.docker.com/engine/swarm/) provides us with many of the needed underlying technologies to use [Apache Mesos](http://mesos.apache.org/). E.g. overlay networking, service orchestration and declarative infrastructure.

> Provisioning may take a while, because the images are pulled in the background

We use the `kombinat.yml` to provision the Swarm with our Mesos stack.

## Setup

> Please, do a `vagrant plugin update` before you continue, as to make sure that you do not rely on some old versions of the [Vagrant Ignition Plugin](https://github.com/coreos/vagrant-ignition)

> Please, change the `DISCOVERY_URL` in `config.ign` to a working token for `etcd`, by executing `curl -w "\n" 'https://discovery.etcd.io/new?size=3'`

```bash
vagrant up
```

```bash
sudo echo "172.17.8.2   portainer.kombinat.lan" >> /etc/hosts
sudo echo "172.17.8.2   master.kombinat.lan" >> /etc/hosts
sudo echo "172.17.8.2   marathon.kombinat.lan" >> /etc/hosts
sudo echo "172.17.8.2   chronos.kombinat.lan" >> /etc/hosts
```

## Play with it

> Marathon [http://marathon.kombinat.lan](http://marathon.kombinat.lan), Portainer [http://portainer.kombinat.lan](http://portainer.kombinat.lan), Master [http://master.kombinat.lan](http://master.kombinat.lan)

Run the Swarm manager 

```
vagrant ssh manager
```

```
docker info
docker node ls
```

Run the Swarm worker

```
vagrant ssh worker-1
```

## Container in Overlay Network with Marathon

```json
{
  "id": "/nginx",
  "cmd": null,
  "cpus": 1,
  "mem": 128,
  "disk": 0,
  "instances": 0,
  "acceptedResourceRoles": [
    "*"
  ],
  "container": {
    "type": "DOCKER",
    "volumes": [],
    "docker": {
      "image": "nginx",
      "network": "USER",
      "privileged": false,
      "forcePullImage": false
    }
  },
  "ipAddress": {
    "networkName": "proxy"
  },
  "healthChecks": [
    {
      "gracePeriodSeconds": 300,
      "intervalSeconds": 60,
      "timeoutSeconds": 20,
      "maxConsecutiveFailures": 3,
      "port": 80,
      "path": "/",
      "protocol": "HTTP",
      "ignoreHttp1xx": false
    }
  ]
}
```

# License
[MIT](/LICENSE)
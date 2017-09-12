# coreos-mesos-vagrant

What we test here, is somewhat ambiguous. We use [CoreOS](https://coreos.com/) and [Docker Swarm](https://docs.docker.com/engine/swarm/) to run [Apache Mesos](http://mesos.apache.org/) on top. 

:smirk: Sounds crazy? Because, that it is. Though, [Docker Swarm](https://docs.docker.com/engine/swarm/) provides us with many of the needed underlying technologies to use [Apache Mesos](http://mesos.apache.org/). E.g. overlay networking, service orchestration and declarative infrastructure.

## Setup

> please, do a `vagrant plugin update` before you continue, as to make sure that you do not rely on some old versions of the [Vagrant Ignition Plugin](https://github.com/coreos/vagrant-ignition)

``` 
vagrant up manager --provider virtualbox
```

## Play with it

> Exhibitor [http://172.17.8.2:8181](http://172.17.8.2:8181), Marathon [http://172.17.8.2:8080](http://172.17.8.2:8080), Mesos [http://172.17.8.2:5050](http://172.17.8.2:8181)

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
# swarm-mesos-vagrant

## Setup

``` 
    vagrant up
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

# Rancher container platform deployment

Salt states for Rancher container platform deployment.

Support for:

 * Rancher server - single node with external MySQL database
 * Rancher agents - automatically provisioned on server start
 * Multi-environment support - automatically create new environments and add agents to them (Kubernetes, Swarm and Mesos)
 * Docker registry - it is not automatically added to Rancher environment

Those states are tested on Ubuntu 14.04 and Salt v2016.3.2.

# Configuration options

You can automatically provision Rancher agents to particular environment specifying ```agentEnvironment``` name. Without this agents will be added to Default environment.

```
# Node configuration
nodes:
  master:
    agentEnvironment: Default
    roles:
      - rancher-server
      - rancher-agent
      - docker-registry
  node01:
    agentEnvironment: Default
    roles:
      - rancher-agent
      - mysql-server
  node02:
    agentEnvironment: Kubernetes
    roles:
      - rancher-agent

# Docker settings
docker:
  registry:
    data_path: /var/lib/docker-registry
    port: 5000
    iface: eth1

# Rancher settings
rancher:
  server:
    version: stable
    port: 8080
    iface: eth1
    db:
      name: rancher
      user: rancher
      password: rancher
    # Create additional environments on startup
    environments:
      kubernetes:
        - name: Kubernetes
      swarm:
        - name: Swarm
      mesos:
        - name: Mesos

# Mysql settings
mysql:
  version: 5.7.14
  data_path: /var/lib/mysql
  port: 3306
  iface: eth1
```

# Vagrant

If you want to test this deployment on your local machine inside VMs, the easiest way is to use Vagrant with VirtualBox provider. All you need is to go inside vagrant directory and run:

```
cd vagrant && vagrant up
```
This will bring up 3 VMs, one master, and 3 minion nodes.
Test the connectivity between master and minions:

```
vagrant ssh master
sudo salt -G 'environment:VAGRANT' test.ping
```
If everything is OK you can proceed with the deployment step.

# Deployment

First, you need to run high state to add roles to minions based on ```properties-VAGRANT.sls``` file:

```
sudo salt '*' state.highstate
```
To start Rancher deployment run orchestrate state:

```
sudo salt-run state.orchestrate deploy.rancher pillar='{environment: VAGRANT}'
```
It will take a few minutes to complete. Then you can check Rancher status at ```http://localhost:8080``` and check for available hosts on Rancher default environment:

![Rancher default environment](https://www.dropbox.com/s/x2rh0d6kgbrzyrt/rancher_env.png?raw=true)

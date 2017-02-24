# Rancher container platform deployment

Salt states for Rancher container platform deployment.

Support for:

 * Rancher server - single node with external MySQL database
 * Rancher agents - automatically provisioned on server start
 * Rancher multi-environment support - automatically create new environments and add agents to them (Kubernetes, Swarm and Mesos)
 * Docker registry - it is not automatically added to Rancher environment
 * Kubernetes will be automatically provisioned on one node
 * Support for different providers:
   * Vagrant
   * AWS

Those states are tested on Ubuntu 14.04 and Salt v2016.3.5.

Rancher default environment:
![Rancher default environment](https://www.dropbox.com/s/4vta5amp2igjgo8/rancher_env2.png?raw=true)

Rancher kubernetes environment:
![Rancher kubernetes environment](https://www.dropbox.com/s/n3esrs086z35d6n/rancher_env3.png?raw=true)

# Configuration options

You can automatically provision Rancher agents to a particular environment specifying ```agentEnvironment``` grain. Without it, agents will be added to a Default environment. Depending on provider those can be added to ```properties.sls``` file in Vagrant or if running on AWS inside ```/etc/salt/cloud.maps.d/rancher.conf```.

# Vagrant

If you want to test this deployment on your local machine inside VMs, the easiest way is to use Vagrant with VirtualBox provider:

```
git clone https://github.com/komljen/rancher-salt
cd rancher-salt/providers/vagrant && vagrant up
```
This will bring up 3 VMs, one master, and 3 minion nodes.
Test the connectivity between master and minions:

```
vagrant ssh master
sudo salt '*' test.ping
```
If everything is OK you can proceed with the deployment step. First, you need to run high state to add roles to minions based on ```properties.sls``` file:

```
sudo salt '*' state.highstate
```
Then to start a Rancher deployment run orchestrate state:

```
sudo salt-run state.orchestrate deploy.rancher
```
It will take a few minutes to complete. Then you can check Rancher status at ```http://localhost:8080```.

# AWS EC2

Salt cloud is used for AWS provisioning. The easiest way is to run provisioning from prepared docker container which has salt and awscli tools installed with prepared config files. You can  run this salt-cloud container in background and connect to it when needed:

```
docker run -d -e AWS_ACCESS_KEY_ID=KEY \
              -e AWS_SECRET_ACCESS_KEY=SECRET \
              -e AWS_DEFAULT_REGION=us-west-2 \
              -e AWS_DEFAULT_AZ=us-west-2a \
              -e AWS_AMI_ID=ami-d732f0b7 \
              --name salt-cloud \
              komljen/salt-cloud
```
Then check for logs and attach to a running container:

```
docker logs -f salt-cloud
docker exec -i -t salt-cloud bash
```

If everything is fine you can start provisioning (master will start first and then all minion nodes will start in parallel):

```
salt-cloud -m /etc/salt/cloud.maps.d/rancher.conf -P -y
```

Now you can connect to the master node using new pem key /etc/salt/salt_cloud_key.pem. Check your master public IP address with:

```
salt-cloud -Q
ssh -i /etc/salt/salt_cloud_key.pem ubuntu@<master_public_ip>
```

Check environment and if all minions are connected deploy rancher:

```
sudo salt '*' test.ping
sudo salt-run state.orchestrate deploy.rancher
```

To access rancher web UI at ```http://AWS_MASTER_PUBLIC_DNS:8080``` you need to open 8080 port first.

If you want to destroy all instances (EBS volumes will be deleted also) run following command:

```
salt-cloud -m /etc/salt/cloud.maps.d/rancher.conf -d -y
```

**NOTE:** Do not delete container until you first copy .pem key from it! Otherwise, you will not be able to log into instances.

```
docker cp salt-cloud:/etc/salt/salt_cloud_key.pem .
docker rm -f salt-cloud
```

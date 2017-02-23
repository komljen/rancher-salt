# Node configuration
nodes:
  master:
    agentEnvironment: Default
    roles:
      - rancher-server
      - rancher-agent
      - docker-registry
  node01:
    agentEnvironment: Kubernetes
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
    #iface: eth0

# Rancher settings
rancher:
  server:
    version: v1.4.1
    port: 8080
    #iface: eth0
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
  #iface: eth0


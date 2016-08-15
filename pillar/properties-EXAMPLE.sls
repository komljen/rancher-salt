# Node configuration
nodes:
  master:
    roles:
      - rancher-server
      - rancher-agent
      - docker-registry
  node01:
    roles:
      - rancher-agent
      - mysql-server
  node02:
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

# Mysql settings
mysql:
  version: 5.7.14
  data_path: /var/lib/mysql
  port: 3306
  iface: eth1

# vi: set ft=yaml.jinja :
{% set test = salt['pillar.get']('test', 'False') %}

docker_setup:
  salt.state:
    - tgt: '*'
    - sls: docker
    - test: {{ test }}

docker_registry_setup:
  salt.state:
    - tgt: 'roles:docker-registry'
    - tgt_type: grain
    - sls: docker.registry
    - test: {{ test }}
    - require:
      - salt: docker_setup

mysql_server_setup:
  salt.state:
    - tgt: 'roles:mysql-server'
    - tgt_type: grain
    - sls: docker.mysql
    - test: {{ test }}
    - require:
      - salt: docker_setup

rancher_server_setup:
  salt.state:
    - tgt: 'roles:rancher-server'
    - tgt_type: grain
    - sls: docker.rancher.server
    - test: {{ test }}
    - require:
      - salt: docker_setup

rancher_agent_setup:
  salt.state:
    - tgt: 'roles:rancher-agent'
    - tgt_type: grain
    - sls: docker.rancher.agent
    - test: {{ test }}
    - require:
      - salt: rancher_server_setup


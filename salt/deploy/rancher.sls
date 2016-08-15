# vi: set ft=yaml.jinja :
{% set force = salt['pillar.get']('force', 'False') %}
{% set environment = salt['pillar.get']('environment') %}
{% set test = salt['pillar.get']('test', 'False') %}

{% if environment %}
docker_setup:
  salt.state:
    - tgt: 'environment:{{ environment }}'
    - tgt_type: grain
    - sls: docker
    - test: {{ test }}
    - pillar:
        environment: {{ environment }}

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
    - tgt: 'G@roles:mysql-server and G@environment:{{ environment }}'
    - tgt_type: compound
    - sls: docker.mysql
    - test: {{ test }}
    - pillar:
        environment: {{ environment }}
    - require:
      - salt: docker_setup

rancher_server_setup:
  salt.state:
    - tgt: 'G@roles:rancher-server and G@environment:{{ environment }}'
    - tgt_type: compound
    - sls: docker.rancher.server
    - test: {{ test }}
    - pillar:
        environment: {{ environment }}
    - require:
      - salt: docker_setup

rancher_agent_setup:
  salt.state:
    - tgt: 'G@roles:rancher-agent and G@environment:{{ environment }}'
    - tgt_type: compound
    - sls: docker.rancher.agent
    - test: {{ test }}
    - pillar:
        environment: {{ environment }}
    - require:
      - salt: rancher_server_setup
{% endif %}

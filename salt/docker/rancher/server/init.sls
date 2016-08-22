# vi: set ft=yaml.jinja :
{% import 'docker/global_vars.jinja' as conf with context %}
{% set tag = salt['pillar.get']('rancher:server:version', 'stable') %}
{% set port = salt['pillar.get']('rancher:server:port', 8080) %}
{% set mysql_iface = salt['pillar.get']('mysql:iface', 'eth0') %}
{% if grains['provider'] == 'VAGRANT' %}
  {% set mysql_iface = 'eth1' %}
{% endif %}
{% set mysql_net = salt['mine.get']('roles:mysql-server','network.interfaces','grain').itervalues().next() %}
{% set mysql_port = salt['pillar.get']('mysql:port', 3306) %}

include:
  - .environments

rancher_image:
  dockerng.image_present:
    - name: rancher/server:{{ tag }}

rancher_container:
  dockerng.running:
    - name: rancher-server
    - image: rancher/server:{{ tag }}
    - environment:
      - CATTLE_DB_CATTLE_MYSQL_HOST: {{ mysql_net[mysql_iface]['inet'][0]['address'] }}
      - CATTLE_DB_CATTLE_MYSQL_PORT: '{{ mysql_port }}'
      - CATTLE_DB_CATTLE_MYSQL_NAME: {{ conf.rancher_db_name }}
      - CATTLE_DB_CATTLE_USERNAME: {{ conf.rancher_db_user }}
      - CATTLE_DB_CATTLE_PASSWORD: {{ conf.rancher_db_password }}
    - port_bindings:
      - {{ port }}:8080
    - restart_policy: always
    - require:
      - dockerng: rancher_image
    - require_in:
      - cmd: rancher_server_api_wait

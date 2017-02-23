# vi: set ft=yaml.jinja :
{% import 'docker/global_vars.jinja' as conf with context %}
{% set tag = salt['pillar.get']('rancher:server:version', 'stable') %}
{% set rancher_port = salt['pillar.get']('rancher:server:port', 8080) %}
{% set mysql_iface = salt['pillar.get']('mysql:iface', 'eth0') %}
{% set rancher_iface = salt['pillar.get']('rancher:server:iface', 'eth0') %}
{% if grains['provider'] == 'VAGRANT' %}
  {% set mysql_iface = 'eth1' %}
  {% set rancher_iface = 'eth1' %}
{% endif %}
{% set rancher_ip = salt['network.ip_addrs'](rancher_iface)[0] %}
{% set mysql_net = salt['mine.get']('roles:mysql-server','network.interfaces','grain').itervalues().next() %}
{% set mysql_port = salt['pillar.get']('mysql:port', 3306) %}

include:
  - common.jq

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
      - {{ rancher_port }}:8080
    - restart_policy: always
    - require:
      - dockerng: rancher_image

rancher_server_api_wait:
  cmd.run:
    - name: |
        wget --retry-connrefused --tries=30 -q --spider \
             http://{{ rancher_ip }}:{{ rancher_port }}/v2-beta && sleep 10
    - unless: curl -s --connect-timeout 1 http://{{ rancher_ip }}:{{ rancher_port }}/v2-beta
    - require:
      - dockerng: rancher_container

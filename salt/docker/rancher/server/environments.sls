# vi: set ft=yaml.jinja :
{% import 'docker/global_vars.jinja' as conf with context %}
{% set rancher_iface = salt['pillar.get']('rancher:server:iface', 'eth0') %}
{% if grains['provider'] == 'VAGRANT' %}
  {% set rancher_iface = 'eth1' %}
{% endif %}
{% set rancher_ip = salt['network.ip_addrs'](rancher_iface)[0] %}
{% set rancher_port = salt['pillar.get']('rancher:server:port', 8080) %}
{% set rancher_environments = salt['pillar.get']('rancher:server:environments') %}

{% if rancher_environments %}
{% for env in rancher_environments %}
{% set rancher_env_name = salt['pillar.get']('rancher:server:environments:' + env + ':name') %}
{% set rancher_env_id = salt['cmd.run']('curl -s "http://' + rancher_ip + ':' + rancher_port|string + '/v2-beta/projectTemplates?name=' + rancher_env_name + '" | jq ".data[0].id"') %}
add_{{ env }}_environment:
  cmd.run:
    - name: |
        curl -s \
             -X POST \
             -H 'Accept: application/json' \
             -H 'Content-Type: application/json' \
             -d '{"name":"{{ rancher_env_name }}", "projectTemplateId":{{ rancher_env_id }}, "allowSystemRole":false, "members":[], "virtualMachine":false, "servicesPortRange":null}' \
             'http://{{ rancher_ip }}:{{ rancher_port }}/v2-beta/projects'
    - unless: |
        curl -s 'http://{{ rancher_ip }}:{{ rancher_port }}/v1/projects' \
             | jq .data[].name \
             | grep -w '{{ rancher_env_name }}'
{% endfor %}
{% endif %}

# vi: set ft=yaml.jinja :
{% import 'docker/global_vars.jinja' as conf with context %}
{% set rancher_iface = salt['pillar.get']('rancher:server:iface', 'eth0') %}
{% set rancher_net = salt['mine.get']('roles:rancher-server','network.interfaces','grain').itervalues().next() %}
{% set rancher_port = salt['pillar.get']('rancher:server:port', 8080) %}
{% set rancher_environment = salt['pillar.get']('nodes:' + conf.hostname + ':agentEnvironment', 'Default') %}

agent_registration_module:
  pip.installed:
    - name: rancher-agent-registration

rancher_server_api_wait:
  cmd.run:
    - name: |
        wget --retry-connrefused --tries=30 -q --spider \
             http://{{ rancher_net[rancher_iface]['inet'][0]['address'] }}:{{ rancher_port }}/v1
    - unless: curl -s --connect-timeout 1 http://{{ rancher_net[rancher_iface]['inet'][0]['address'] }}:{{ rancher_port }}/v1

rancher_agent_container:
  cmd.run:
    - name: |
        rancher-agent-registration --url http://{{ rancher_net[rancher_iface]['inet'][0]['address'] }}:{{ rancher_port }} \
                                   --key KEY --secret SECRET --environment {{ rancher_environment }}
    - unless: docker inspect rancher-agent
    - require:
      - cmd: rancher_server_api_wait
      - pip: agent_registration_module

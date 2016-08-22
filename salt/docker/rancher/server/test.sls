# vi: set ft=yaml.jinja :
{% import 'docker/global_vars.jinja' as conf with context %}
{% set rancher_iface = salt['pillar.get']('rancher:server:iface', 'eth0') %}
{% set rancher_ip = salt['network.ip_addrs'](rancher_iface)[0] %}
{% set rancher_port = salt['pillar.get']('rancher:server:port', 8080) %}
{% set rancher_environments = salt['pillar.get']('rancher:server:environments') %}

query_example:
  http.query:
    - name: 'http://{{ rancher_ip }}:{{ rancher_port }}/v1'
    - status: 200
    - text: False
    - text_out: /tmp/url_download.txt
    - dict: True
    - body: False


{% set response = salt.http.query('http://192.168.33.10:8080/v1')|load_json %}
{{ response.body }}

#nested_grain_with_complex_value:
#  grains.present:
#    - name: rancher:api
#    - value:
#      - secret: 

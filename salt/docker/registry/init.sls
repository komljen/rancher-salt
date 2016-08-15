# vi: set ft=yaml.jinja :
{% set data_path = salt['pillar.get']('docker:registry:data_path') %}
{% if not data_path %}
  {% set data_path = '/var/lib/docker-registry' %}
{% endif %}
{% set tag = salt['pillar.get']('docker:registry:tag') %}
{% set registry_port = salt['pillar.get']('docker:registry:port', 5000) %}

registry_image:
  dockerng.image_present:
    - name: registry:{{ tag }}

registry_stop_remove:
  cmd.run:
    - name: |
        docker stop -t 30 registry || true
        docker rm -f registry || true
    - unless: |
         docker inspect --format {% raw %}"{{ .Image }}"{% endraw %} registry \
                | grep -w $(docker inspect --format {% raw %}"{{ .Id }}"{% endraw %} \
                  registry:{{ tag }})
    - require:
      - dockerng: registry_image

registry_container:
  dockerng.running:
    - name: registry
    - image: registry:{{ tag }}
    - port_bindings:
      - {{ registry_port }}:5000
    - binds:
      - {{ data_path }}:/var/lib/registry
    - restart_policy: always
    - require:
      - dockerng: registry_image

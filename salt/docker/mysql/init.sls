# vi: set ft=yaml.jinja :
{% import 'docker/global_vars.jinja' as conf with context %}
{% set tag = salt['pillar.get']('mysql:version', '5.7.14') %}
{% set data_path = salt['pillar.get']('mysql:data_path', '/var/lib/mysql') %}
{% set port = salt['pillar.get']('mysql:port', 3306) %}

mysql_image:
  dockerng.image_present:
    - name: mysql:{{ tag }}

mysql_container:
  dockerng.running:
    - name: mysql-server
    - image: mysql:{{ tag }}
    - environment:
      - MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
      - MYSQL_DATABASE: {{ conf.rancher_db_name }}
      - MYSQL_USER: {{ conf.rancher_db_user }}
      - MYSQL_PASSWORD: {{ conf.rancher_db_password }}
    - port_bindings:
      - {{ port }}:3306
    - binds:
      - {{ data_path }}:/var/lib/mysql
    - restart_policy: always
    - command: "--character-set-server=utf8 --collation-server=utf8_general_ci"
    - require:
      - dockerng: mysql_image

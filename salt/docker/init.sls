# vi: set ft=yaml.jinja :
{% set kernelrelease = salt['grains.get']('kernelrelease') %}
{% set docker_version = salt['pillar.get']('docker:version') %}
{% set dockerpy_version = salt['pillar.get']('docker:dockerpy_version') %}
{% set pip_version = '8.1.2' %}

include:
  - common.python-setuptools

install_pip:
  cmd.run:
    - name: easy_install pip=={{ pip_version }}
    - unless: pip --version | grep -w {{ pip_version }}
    - reload_modules: True
    - require:
      - pkg: python-setuptools

dockerpy_module:
  pip.installed:
    - name: docker-py=={{ dockerpy_version }}
    - require:
      - cmd: install_pip

# https://github.com/saltstack/salt/issues/35455
salt-minion:
  service.running:
    - watch:
      - pip: dockerpy_module

docker_repo:
  pkgrepo.managed:
    - name: deb https://apt.dockerproject.org/repo ubuntu-trusty main
    - file: /etc/apt/sources.list.d/docker.list
    - keyserver: hkp://p80.pool.sks-keyservers.net:80
    - keyid: 58118E89F3A912897C070ADBF76221572C52609D
    - require_in:
      - pkg: docker-engine

linux-kernel-deps:
  pkg.installed:
    - pkgs:
      - linux-image-extra-{{ kernelrelease }}
      - aufs-tools
  cmd.run:
    - name: modprobe aufs
    - unless: modinfo aufs
    - require_in: 
      - pkg: docker-engine

lxc-docker:
  pkg.purged:
    - name: lxc-docker-*
    - require_in:
      - pkg: docker-engine

docker-engine:
  pkg.installed:
    - version: {{ docker_version }}
    - refresh: True
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker-engine
    - watch:
      - file: /etc/default/docker
      - pkg: linux-kernel-deps
      - pkg: docker-engine

/etc/default/docker:
  file.managed:
    - template: jinja
    - source: salt://docker/etc/docker
    - require:
      - pkg: docker-engine

# vi: set ft=yaml.jinja :

base:
  '*':
    - mine
    - docker

  'environment:ENV_NAME':
    - match: grain
    - properties-ENV_NAME

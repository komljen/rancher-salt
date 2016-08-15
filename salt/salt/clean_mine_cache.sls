# vi: set ft=yaml.jinja :

clean_mine_cache:
  cmd.run:
    - name: |
        rm /var/cache/salt/master/minions/*/mine.p && \
        salt '*' mine.update && \
        sleep 2

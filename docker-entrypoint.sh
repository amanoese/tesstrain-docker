#!/bin/bash

if [ -z "$(ls -A /var/tesstrain/data|grep -v '^.gitkeep$')" ];then
  bash -v -c 'tar -zxf data_backup.tar.gz -C /var/tesstrain'
fi

exec "$@"

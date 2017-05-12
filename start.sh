#!/bin/bash

# Fire up supervisord
mkdir /srv/data/"$CLUSTER_NAME"
/usr/bin/supervisord -n -c /etc/supervisord.conf

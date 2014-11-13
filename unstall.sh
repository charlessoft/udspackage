#!/bin/bash 
riak stop
rpm -e riak-1.4.0-1
rm -fr /etc/riak
rm -fr /var/lib/riak

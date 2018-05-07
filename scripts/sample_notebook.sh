#!/bin/bash

cd /usr/local/samples
sudo /usr/sbin/nginx
jupyter notebook --no-browser --NotebookApp.token="" &
sudo /usr/sbin/sshd -D

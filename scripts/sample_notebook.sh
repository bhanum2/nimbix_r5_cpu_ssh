#!/bin/bash

sudo chmod 600 /bin/sh
cd /usr/local/samples
sudo /usr/sbin/nginx
jupyter notebook --no-browser --NotebookApp.token="" &
sudo /usr/sbin/sshd -D

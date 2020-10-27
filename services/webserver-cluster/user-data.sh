#!/bin/bash

sudo yum update -y
sudo yum install httpd.x86_64 -y

sudo systemctl start httpd.service
sudo systemctl enable httpd.service

sudo cat > /var/www/html/index.html <<EOF
    <h1>Hellow launch config user data $(hostname -f)</h1>
    <h3>Database Address</h3>
    <h5>Database Port</h5>
EOF

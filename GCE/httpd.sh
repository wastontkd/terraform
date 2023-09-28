#!/bin/bash

sudo apt update
sudo apt install apache2 && sudo systemctl start apache2 >> log_install.txt

date >> log_install.txt
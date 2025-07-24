#!/bin/bash
  apache2 -v
  systemctl stop apache2 # Stop Apache
  systemctl disable apache2 # Disable Apache
  apt purge apache2 -y # Purge Apache packages and clean up dependencies
  apt autoremove -y
  apt autoclean
  rm -rf /etc/apache2 # Remove Apache configuration directory  
  rm -rf /var/log/apache2 # Remove Apache log files
  rm -rf /var/www/html # Remove default web root (CAUTION: deletes /var/www/html)
  rm -rf /var/www
  which apache2 || echo "apache2 not found" # Verify apache2 binary no longer exists
  systemctl status apache2 || echo "apache2 service not found" # Verify apache2 service no longer exists

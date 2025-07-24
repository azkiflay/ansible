#!/bin/bash
  echo "=== Updating package list ==="
  apt update
  echo "=== Installing Apache2 ==="
  apt install apache2 -y
  echo "=== Recreating default web root directories ==="
  mkdir -p /var/www/html
  chown -R www-data:www-data /var/www
  chmod -R 755 /var/www
  echo "=== Enabling and starting Apache2 service ==="
  systemctl enable apache2
  systemctl start apache2
  echo "=== Verifying Apache2 installation ==="
  apache2 -v || echo "Apache2 not found"
  systemctl status apache2 --no-pager || echo "Apache2 service not found"
  echo "=== Apache2 reinstallation complete! ==="

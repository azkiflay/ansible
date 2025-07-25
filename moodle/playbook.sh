#!/bin/bash
# Moodle as Sample Web Application
## Store info to make substitution of values easier
```bash
    PROTOCOL="http://";
    read -p "Enter the web address (without the http:// prefix, eg domain name mymoodle123.com or IP address 192.168.1.1.): " WEBSITE_ADDRESS # Note: Enter "moodle.local" or publicly registered website name for your Moodle site.
    sudo nano /etc/hosts
    # Add entry for resolving hosts.local --> "127.0.11        localhost.local"
```

## Install the LAMP stack as the webserver
```bash
    sudo apt-get update && sudo apt upgrade -y 
    sudo apt-get -y install apache2 php libapache2-mod-php php-mysql graphviz aspell git clamav php-pspell php-curl php-gd php-intl ghostscript php-xml php-xmlrpc php-ldap php-zip php-soap php-mbstring unzip mariadb-server mariadb-client certbot python3-certbot-apache ufw nano
```
## Get Moodle code using Git
```bash
    cd /var/www/html # Note: may require root privilege?
    sudo git clone https://github.com/moodle/moodle.git 
    cd moodle 
    sudo git checkout origin/MOODLE_500_STABLE 
    sudo git config pull.ff only
```

## Configure specific Moodle requirements
```bash
    sudo mkdir -p /var/www/moodledata
    sudo chown -R www-data:www-data /var/www/moodledata
    sudo find /var/www/moodledata -type d -exec chmod 700 {} \; 
    sudo find /var/www/moodledata -type f -exec chmod 600 {} \;
    PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") 
    sudo sed -i 's/.*max_input_vars =.*/max_input_vars = 5000/' /etc/php/$PHP_VERSION/apache2/php.ini 
    sudo sed -i 's/.*max_input_vars =.*/max_input_vars = 5000/' /etc/php/$PHP_VERSION/cli/php.ini 
    sudo sed -i 's/.*post_max_size =.*/post_max_size = 256M/' /etc/php/$PHP_VERSION/apache2/php.ini 
    sudo sed -i 's/.*post_max_size =.*/post_max_size = 256M/' /etc/php/$PHP_VERSION/cli/php.ini 
    sudo sed -i 's/.*upload_max_filesize =.*/upload_max_filesize = 256M/' /etc/php/$PHP_VERSION/apache2/php.ini 
    sudo sed -i 's/.*upload_max_filesize =.*/upload_max_filesize = 256M/' /etc/php/$PHP_VERSION/cli/php.ini 
    sudo echo "* * * * * /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null" | sudo crontab -u www-data - # Error: "must be privileged to use -u", if last 'sudo' is not present as in the official Moodle instllation web page.
```

## Get the https protocol
```bash
    sudo sed -i '/ServerName/c\    ServerName $WEBSITE_ADDRESS' /etc/apache2/sites-available/000-default.conf
    sudo sed -i '/ServerAlias/c\    ServerAlias www.$WEBSITE_ADDRESS' /etc/apache2/sites-available/000-default.conf
    sudo certbot --apache # "A domain name is required to get https in this step"
    sudo systemctl reload apache2
    PROTOCOL="https://";
```

## Database and user creation
```bash
    MYSQL_MOODLEUSER_PASSWORD=$(openssl rand -base64 6)
    sudo mysql -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    sudo mysql -e "CREATE USER 'moodleuser2'@'localhost' IDENTIFIED BY '$MYSQL_MOODLEUSER_PASSWORD';"
    sudo mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER ON moodle.* TO 'moodleuser2'@'localhost';"
    echo "Your Moodle user password is $MYSQL_MOODLEUSER_PASSWORD. Write this down as you will need it in a web browser install"
    # Your Moodle user password is 3gqxSWin. Write this down as you will need it in a web browser install
```

## Moodle configuration on the Web Server
```bash
    sudo chown -R www-data:www-data /var/www/html/moodle
    MOODLE_ADMIN_PASSWORD=$(openssl rand -base64 6)
    sudo -u www-data /usr/bin/php /var/www/html/moodle/admin/cli/install.php --non-interactive --lang=en --wwwroot="$PROTOCOL$WEBSITE_ADDRESS/moodle" --dataroot=/var/www/moodledata --dbtype=mariadb --dbhost=localhost --dbname=moodle --dbuser=moodleuser2 --dbpass="$MYSQL_MOODLEUSER_PASSWORD" --fullname="Moodle Docs Step by Step Guide" --shortname="SG" --adminuser=admin --summary="" --adminpass="$MOODLE_ADMIN_PASSWORD" --adminemail=joe@123.com --agree-license 
    # Installation completed successfully.
    # Note: moodleuser2 due to repeated command runs. Otherwise, Error: "PHP Warning:  mysqli::__construct(): (HY000/1045): Access denied for user 'moodleuser'@'localhost' (using password: YES) in /var/www/html/moodle/lib/dml/mysqli_native_moodle_database.php on line 91 --> "We could not connect to the database you specified. Please check your database settings."

    # Error: Could not open input file: /var/www/html/moodle/admin/cli/install.php
    echo "Moodle installation completed successfully. You can now log on to your new Moodle at $PROTOCOL$WEBSITE_ADDRESS/moodle as admin with $MOODLE_ADMIN_PASSWORD and complete your site registration"
    # Moodle installation completed successfully. You can now log on to your new Moodle at http://moodle.local/moodle as admin with 
    "+j0T+YVK" and complete your site registration
```

## Configure SQL Backups
```bash
    BACKUP_USER_PASSWORD=$(openssl rand -base64 6)
    sudo mysql <<EOF
    CREATE USER 'backupuser'@'localhost' IDENTIFIED BY '${BACKUP_USER_PASSWORD}';
    GRANT LOCK TABLES, SELECT ON moodle.* TO 'backupuser'@'localhost';
    FLUSH PRIVILEGES;
    EOF

    sudo cat > /root/.my.cnf <<EOF
    [client]
    user=backupuser
    password=${BACKUP_USER_PASSWORD}
    EOF
    chmod 600 /root/.my.cnf

    mkdir -p /var/backups/moodle && chmod 700 /var/backups/moodle && chown root:root /var/backups/moodle

    (crontab -l 2>/dev/null; echo "0 2 * * * mysqldump --defaults-file=/root/.my.cnf moodle > /var/backups/moodle/moodle_backup_\$(date +\%F).sql") | crontab -
    (crontab -l 2>/dev/null; echo "0 3 * * * find /var/backups/moodle -name \"moodle_backup_*.sql\" -type f -mtime +7 -delete") | crontab -
```

## Security
```bash
    sudo find /var/www/html/moodle -type d -exec chmod 755 {} \; 
    sudo find /var/www/html/moodle -type f -exec chmod 644 {} \;
    sudo mariadb-secure-installation
    sudo ufw allow 22/tcp
    sudo ufw --force enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow www 
    sudo ufw allow 'Apache Full'
```

## Setting up antivirus on the server
```bash
    sudo apt install -y clamav
    # Site Administration > Plugins > Antivirus plugins > Manage antivirus plugins > ClamAV® antivirus and 'enable' the plugin by opening the eye.
    # Add this command to the 'Settings' for ClamAV --> /usr/bin/clamscan
    sudo apt install -y clamav-daemon # activate the ClamAV® daemon process
    # Site Administration > Plugins > Antivirus plugins > Manage antivirus plugins > ClamAV® antivirus and 'enable' the plugin by opening the eye.
    # Change the ClamAV® command command to the 'Settings' for ClamAV --> /usr/bin/clamdscan
   
```
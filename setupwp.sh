#!/bin/bash

echo "====================================================="
echo "====Install Wordpress V.1.0 by Ramdani IDCloudHost==="
echo "====================================================="
echo "1. Install Nginx"
echo "2. Install MariaDB"
echo "3. Install PHP=FPM"
echo "4. Install SSL Let's Encrypt"
echo "============================================"

echo "============================================="
echo "Membuat Website Wordpress"
echo "============================================="

read -p "Nama Domain/subdomain = " domain
read -p "Judul Website = " wpjudul
read -p "Username = " wpadmin
read -p "Password = " wppass
read -p "Email admin = " wpemail
read -p "Email SSL Info = " emailssl

echo "update dan upgrade"
apt update && apt upgrade -y

echo "Install Nginx"
apt install nginx -y
echo "Nginx berhasil di install"

echo "Install dan Add repo PPA for PHP 7.4"
sudo apt install software-properties-common 
sudo add-apt-repository ppa:ondrej/php -y
apt install php7.4-fpm php7.4-common php7.4-xml php7.4-zip php7.4-mysql php7.4-mbstring php7.4-json php7.4-curl php7.4-gd php7.4-pgsql -y   
echo "install PHP 7.4 Selesai"

echo "Install database mariadb"
apt install mariadb-server -y
echo "Install MariaDB Berhasil"
echo "============================================"
echo "======LEMP Stack Berhasil di Install========"
echo "============================================"
echo "Install WP-CLI"
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

echo "============================================"
echo "=======Download wordpress latest============"
echo "============================================"
wget -c https://wordpress.org/latest.tar.gz -O wordpress.tar.gz
echo "Extracting tarball wordpress..."
tar xzvf wordpress.tar.gz
mv wordpress /var/www/$domain
chmod -R 755 /var/www/$domain
chown -R www-data:www-data /var/www/$domain
#variable database
dbuser="wp_user"
dbpass="Mkdj2kdnJNks"
dbname="wp_db"

#create wp config
echo "========================================="
echo "Membuat konfigurasi file..."
cd /var/www/$domain
cp wp-config-sample.php wp-config.php
echo "==========Replace wp-config.php=============="
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php
echo "==========Konfig Permission=============="
chown -R www-data:www-data wp-config.php
mkdir wp-content/uploads
chmod 775 wp-content/uploads
echo
echo "Installing wordpress..."
echo "create db name"
mysql -e "CREATE DATABASE $dbname;"

echo "Creating new user..."
mysql -e "CREATE USER '$dbuser'@'%' IDENTIFIED BY '$dbpass';"
echo "User Berhasil dibuat!"

echo "Granting ALL privileges on $dbname to $dbuser!"
mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'%';"
mysql -e "FLUSH PRIVILEGES;"
echo "Berhasil aman :)"

wp core install --url=http://${domain} --title="$wpjudul" --admin_user="$wpadmin" --admin_password="$wppass" --admin_email="$wpemail" --allow-root

echo "WP salts"
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php
#variable
uri="$uri"
query_string="$query_string"
fastcgi_script_name="$fastcgi_script_name"
realpath_root="$realpath_root"


echo "======================================"
echo "========Konfig Server Block==========="
echo "======================================"

touch /etc/nginx/sites-available/$domain.conf
cat > /etc/nginx/sites-available/$domain.conf <<EOF
server {
    listen 80;
    server_name www.$domain $domain;
    root /var/www/$domain;
    index index.php index.html index.htm;

    location / {
      try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
      try_files \$fastcgi_script_name =404;
      include fastcgi_params;
      fastcgi_pass    unix:/run/php/php7.4-fpm.sock;
      fastcgi_index   index.php;
      fastcgi_param DOCUMENT_ROOT    \$realpath_root;
      fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name; 
    }

    access_log /var/log/nginx/${domain}_access.log;
    error_log /var/log/nginx/${domain}_error.log;
}
EOF

ln -s /etc/nginx/sites-available/${domain}.conf /etc/nginx/sites-enabled/ 
echo "======================================"
echo "=============Konfig Aman=============="
echo "======================================"
echo
echo "======================================"
echo "======Install SSL Let's Encrypt======="
echo "======================================"

apt install certbot python3-certbot-nginx -y
certbot run -n --nginx --agree-tos -d $domain,www.$domain  -m  $emailssl  --redirect

cat > /root/${domain}-akses.txt << EOF
==============================================================
=============Selamat Website wordpress berhasil dibaut!=========
=============== by Ramdani IDCloudHost =======================
--------------------------------------------------------------

Alamat Website: https://${domain}
Login Website: https://${domain}/wp-admin
-----------------------------------------------
Email Website: ${wpemail}
Username: ${wpadmin}
Password: ${wppass}
===============================================
Akses database
Nama Database: ${dbname}
User Database: ${dbuser}
Password Database: ${dbpass}

Lokasi File txt ini: /root/${domain}-akses.txt
Lokasi Doucment root: /var/www/${domain}
EOF
cat /root/${domain}-akses.txt
echo "========================="
echo "Instalasi Beres 100%."
echo "=========================" 

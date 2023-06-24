# Shell-script-install-wordpress-automation
Shell bash script install wordpress automation on VPS

Cara install 
Silakan bisa diclone lalu jalankan bash nama shell.sh
bash script ini terdiri dari LEMP stack.
1. Nginx
2. PHP-FPM
3. MariaDB

# Fitur pada bash script ini.
1. Input domain
2. username WP
3. password WP

Untuk subdomain sementara bisa hilangkan opsi www.domain.tld pada installasi SSL Let'Ecrypt.

`$ certbot run -n --nginx --agree-tos -d $domain -m  $emailssl  --redirect`

# Spesifikasi Shell
1. PHP-FPM 7.4
2. Wordpress Latest
3. Nginx Latest
4. MariaDB Latest
5. WP-CLI
6. SSL Let's Encrypt

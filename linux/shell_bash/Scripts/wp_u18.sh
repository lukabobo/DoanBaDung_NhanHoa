#!/bin/bash
#tao database va user cho wordpress
DIRECTORY=$(cd `dirname $0` && pwd)
create_database(){
    echo -n "MariaDB Host (localhost): "
    read mariahost
    if [ "$mariahost" = "" ]
    then
	mariahost="localhost"
    fi
    echo -n "Nhap ten DB: "
    read mariadb

    echo -n "Nhap ten user quan ly DB: "
    read mariauser

    echo -n "Nhap password cho user: "
    read mariapass

mysql -u root <<EOF
CREATE DATABASE $mariadb;
CREATE USER $mariauser@$mariahost IDENTIFIED BY '$mariapass';
GRANT ALL PRIVILEGES ON $mariadb.* TO $mariauser IDENTIFIED BY '$mariapass';
FLUSH PRIVILEGES;
exit
EOF
}
create_database

#cai dat cac extension php can thiet
apt update -y
apt install -y php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
systemctl restart apache2

#tai wordpress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
# giai nen
tar xzvf latest.tar.gz
# Copy tat ca file trong thu muc wordpress den /var/www/html
cp -Rvf /tmp/wordpress/* /var/www/html/
#den thu muc /var/www/html/
cd /var/www/html/
# copy file config mac dinh
cp wp-config-sample.php wp-config.php
#sua file wp-config.php voi cac thong tin da nhap
sed -e “s/database_name_here/$mariadb/g” wp-config.php
sed -e “s/username_here/$mariauser/g” wp-config.php
sed “s/password_here/$mariapass/g” wp-config.php
#cap quyen so huu thu muc va phan quyen
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/*
#xoa file index mac dinh cua apache
rm -rf /var/www/html/index.html 
# khoi dong lai apache
systemctl restart apache2

echo “Da cai xong wordpress”
#filename: Vagrantfile.provision.sh
#!/usr/bin/env bash

###########################################
# by oneslynxs | ones006@gmail.com        #
#-----------------------------------------#
# + Apache                                #
# + PHP 5.6                               #
# + MySQL 5.7                             #
# + NodeJs, Git, Composer, etc...         #
###########################################



# ---------------------------------------------------------------------------------------------------------------------
# Variables & Functions
# ---------------------------------------------------------------------------------------------------------------------
APP_DATABASE_NAME='app'

echoTitle () {
    echo -e "\033[0;30m\033[42m -- $1 -- \033[0m"
}

# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Virtual Machine Setup'
# ---------------------------------------------------------------------------------------------------------------------
# Update packages
apt-get -y update 
apt-get -y dist-upgrade
apt-get -y install git curl vim

# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing and Setting: Apache'
# ---------------------------------------------------------------------------------------------------------------------
# Install packages
apt-get install -y apache2 libapache2-mod-fastcgi apache2-mpm-worker

# linking Vagrant directory to Apache 2.4 public directory
# rm -rf /var/www
# ln -fs /vagrant /var/www

# Add ServerName to httpd.conf
echo "ServerName localhost" > /etc/apache2/httpd.conf

# Setup hosts file
VHOST=$(cat <<EOF
    <VirtualHost *:80>
      DocumentRoot "/var/www/html"
      ServerName projects.ret
      ServerAlias projects.ret
      <Directory "/var/www/html">
        Options Indexes FollowSymlinks
        AllowOverride All
        Require all granted
        Order allow,deny
        Allow from all
        DirectoryIndex index.php index.html
      </Directory>
    </VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf

# Loading needed modules to make apache work
a2enmod actions fastcgi rewrite
sudo service apache2 restart



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'MYSQL-Database'
# ---------------------------------------------------------------------------------------------------------------------
# Setting MySQL (username: root) ~ (password: password)
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password mysql'
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password mysql'

# Installing packages
apt-get install -y mysql-server-5.7 mysql-client-5.7 mysql-client-core-5.7 mysql-common

# Setup database
mysql -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS $APP_DATABASE_NAME;";
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'mysql';"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'mysql';"

sudo service mysql restart

# Import SQL file
# mysql -uroot -ppassword database < my_database.sql



# ---------------------------------------------------------------------------------------------------------------------
# echoTitle 'Maria-Database'
# ---------------------------------------------------------------------------------------------------------------------
# Remove MySQL if installed
# sudo service mysql stop
# apt-get remove --purge mysql-server-5.6 mysql-client-5.6 mysql-common-5.6
# apt-get autoremove
# apt-get autoclean
# rm -rf /var/lib/mysql/
# rm -rf /etc/mysql/

# Install MariaDB
# export DEBIAN_FRONTEND=noninteractive
# debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password root'
# debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password root'
# apt-get install -y mariadb-server

# Set MariaDB root user password and persmissions
# mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# Open MariaDB to be used with Sequel Pro
# sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mysql/my.cnf

# Restart MariaDB
# sudo service mysql restart



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: PHP'
# ---------------------------------------------------------------------------------------------------------------------
# Add repository
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y python-software-properties software-properties-common

# install php5.6
apt-get install -y php5.6 php5.6-intl php5.6-bcmath php5.6-cli php5.6-common php5.6-curl php5.6-enchant php5.6-gd php5.6-json php5.6-mbstring php5.6-mysql php5.6-pgsql php5.6-zip php5.6-xsl php5.6-xmlrpc

# Remove PHP5
# apt-get purge php5-fpm -y
# apt-get --purge autoremove -y

# Install packages
#apt-get install -y php7.1 php7.1-fpm
#apt-get install -y php7.1-mysql
#apt-get install -y mcrypt php7.1-mcrypt
#apt-get install -y php7.1-cli php7.1-curl php7.1-mbstring php7.1-xml php7.1-mysql
#apt-get install -y php7.1-json php7.1-cgi php7.1-gd php-imagick php7.1-bz2 php7.1-zip



# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Setting: PHP with Apache'
# ---------------------------------------------------------------------------------------------------------------------
#apt-get install -y libapache2-mod-php7.1
apt-get install -y libapache2-mod-php5.6

# Enable php modules
# php71enmod mcrypt (error)

# Trigger changes in apache
#a2enconf php7.1-fpm
sudo service apache2 reload

# Packages Available:
# apt-cache search php7-*



# ---------------------------------------------------------------------------------------------------------------------
# echoTitle 'Installing & Setting: X-Debug'
# ---------------------------------------------------------------------------------------------------------------------
# cat << EOF | sudo tee -a /etc/php/7.1/mods-available/xdebug.ini
# xdebug.scream=1
# xdebug.cli_color=1
# xdebug.show_local_vars=1
# EOF



# ---------------------------------------------------------------------------------------------------------------------
# Others
# ---------------------------------------------------------------------------------------------------------------------
echoTitle 'Installing: Node 6 and update NPM'
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs
npm install npm@latest -g

echoTitle 'Installing: Git'
apt-get install -y git

echoTitle 'Installing: Composer'
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer



# ---------------------------------------------------------------------------------------------------------------------
# Others
# ---------------------------------------------------------------------------------------------------------------------
# Output success message
echoTitle "Your machine has been provisioned"
echo "-------------------------------------------"
echo "MySQL is available on port 3306 with username 'root' and password 'mysql'"
echo "(you have to use 127.0.0.1 as opposed to 'localhost')"
echo "Apache is available on port 80"
echo -e "Head over to http://192.168.254.57 to get started"
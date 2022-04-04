#!/bin/bash
sudo apt update
sudo apt upgrade -y

# Installation d'apache2, php et des extensions complémentaires
echo "============================================="
echo "Installation d'apache2 et de php + extensions"
echo "============================================="
sudo apt install -y apache2 php unzip
sudo apt install -y php-{curl,dom,exif,fileinfo,json,mbstring,mysqli,imagick,xml,zip,gd,iconv,simplexml,xmlreader}
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "================================"
echo "Configuration du serveur Mariadb"
echo "================================"
sudo apt install -y mariadb-{client,server}
read -p "Mot de passe pour mysql root : " secret
sudo mysql_secure_installation <<EOF

y
$secret
$secret
y
y
y
y
EOF

echo "============================================"
echo "Configuration de la base de donnée Wordpress"
echo "============================================"
read -p "Nom d'utilisateur : " db_user
read -p "Nom de la base de donnée : " db_name
read -p "Mot de passe : " db_password
# On supprime la base de données du même non si elle existe...
sudo mysql -u root --execute "DROP DATABASE IF EXISTS $db_name;"
sudo mysql -u root --execute "CREATE DATABASE $db_name;"
sudo mysql -u root --execute "GRANT ALL ON $db_name.* TO $db_user@localhost IDENTIFIED BY '$db_password';"
sudo mysql -u root --execute "FLUSH PRIVILEGES;"

echo "============================================"
echo "Téléchargement et extraction de Wordpress"
echo "============================================"
if [ -f latest-fr_BE.zip ] # si le fichier existe
then
	rm -f latest-fr_BE.zip # on le supprime avant de le télécharger à nouveau
fi
wget https://fr-be.wordpress.org/latest-fr_BE.zip

if [ -d wordpress ]  # si le répertoire existe
then
	rm -fr wordpress # on le supprime avant extraction
fi
unzip latest-fr_BE.zip

sudo rm -fr /var/www/html/*
sudo cp -ar wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html

echo "========================"
echo "Installation terminée..."
echo "========================"
# la commande hostame -I donne l'adresse IP du serveur
echo "Veuillez continuer l'installation en navigant sur "$(hostname -I)
echo "Pour rappel, voici vos information de connection à la base de données :"
echo "Base de données : "$db_name
echo "Utilisateur : "$db_user
echo "Mot de passe : "$db_password
read -p "Appuyez sur une touche pour terminer..."
#!/bin/bash

# Function to copy site content to Nginx site folder
copy_site_content() {
    echo "Copying site content to /var/www/html"
    cp -r site/* /var/www/html/
    chown -R www-data:www-data /var/www/html/
    chmod -R 755 /var/www/html/
    echo "Site content copied successfully."
}

# Main script

# Install Nginx, Certbot, and Python3
sudo apt install nginx certbot python3-certbot-nginx -y

# Read the domain from user input
read -p "Your Domain: " DOMAIN

# Copy site content to /var/www/html
copy_site_content

# Configure Nginx settings
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sed -i "s/_;/$DOMAIN;/" "/etc/nginx/sites-available/$DOMAIN"
sed -i "s/ default_server//" "/etc/nginx/sites-available/$DOMAIN"
sed -i "53 r /root/reverse/reverse.txt" "/etc/nginx/sites-available/$DOMAIN"

# Obtain SSL certificate using Certbot
certbot --nginx -d $DOMAIN --register-unsafely-without-email

# Restart Nginx
systemctl restart nginx

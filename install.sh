#!/bin/bash


add_iptables_rules() {
    echo "Adding iptables rules to block traffic from www.speedtest.net"
    iptables -I INPUT -s www.speedtest.net -j DROP
    iptables -I FORWARD -p tcp -d www.speedtest.net -j DROP
}


copy_site_content() {
    echo "Removing default index file"
    rm -f /var/www/html/index.nginx-debian.html
    
    echo "Copying site content to /var/www/html"
    cp -r site/* /var/www/html/
    chown -R www-data:www-data /var/www/html/
    chmod -R 755 /var/www/html/
    echo "Site content copied successfully."
}


sudo apt update
sudo apt install nginx certbot python3-certbot-nginx python3-pip iptables-persistent -y


add_iptables_rules


read -p "Your Domain: " DOMAIN


copy_site_content


cp /etc/nginx/sites-available/default /etc/nginx/sites-available/$DOMAIN
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sed -i "s/_;/$DOMAIN;/" "/etc/nginx/sites-available/$DOMAIN"
sed -i "s/ default_server//" "/etc/nginx/sites-available/$DOMAIN"
sed -i "53 r /root/ngn/reverse.txt" "/etc/nginx/sites-available/$DOMAIN"


certbot --nginx -d $DOMAIN --register-unsafely-without-email


iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6


systemctl restart nginx


service iptables-persistent save

echo "Your server configuration is complete."

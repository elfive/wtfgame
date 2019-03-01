#!/bin/bash
#title           :glassfish-install.sh
#description     :The script to install Glassfish 4.1.x
#author	         :Mateusz Smolik
#date            :2016-06-15T17:14-0700
#usage           :/bin/bash glassfish-install.sh
#tested-version  :4.1.1
#tested-distros  :Debian 8; Ubuntu 16.04; CentOS 7; Fedora 23
#script-version  :0.0.1
#./asadmin --host localhost --port 41855 enable-secure-admin

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

echo "Updating system..."
yum -y update;
echo "Setup utils and gf..."
yum -y install unzip wget;
adduser \
   --comment 'Glassfish User' \
   --home-dir /home/glassfish \
   glassfish

wget http://download.java.net/glassfish/4.1.1/release/glassfish-4.1.1.zip -P /home/glassfish/;
unzip /home/glassfish/glassfish-4.1.1.zip;
rm -f /home/glassfish/glassfish-4.1.1.zip;
chown -R glassfish:glassfish /home/glassfish;

cat > /etc/systemd/system/glassfish.service << "EOF"
[Unit]
Description = GlassFish Server v4.1
After = syslog.target network.target

[Service]
User=glassfish
ExecStart = /usr/bin/java -jar /home/glassfish/glassfish4/glassfish/lib/client/appserver-cli.jar start-domain
ExecStop = /usr/bin/java -jar /home/glassfish/glassfish4/glassfish/lib/client/appserver-cli.jar stop-domain
ExecReload = /usr/bin/java -jar /home/glassfish/glassfish4/glassfish/lib/client/appserver-cli.jar restart-domain
Type = forking

[Install]
WantedBy = multi-user.target
EOF
systemctl enable glassfish.service;
systemctl start glassfish.service;
firewall-cmd --zone=pubic --add-port=8080/tcp --permanent;
firewall-cmd --zone=pubic --add-port=4848/tcp --permanent;
firewall-cmd --reload;


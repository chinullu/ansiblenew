#!/bin/bash

# Install dependencies
yum -y install java-1.8.0-openjdk.x86_64

# Install TeamCity 9.1.7 to /srv/TeamCity
wget -c https://download.jetbrains.com/teamcity/TeamCity-9.1.7.tar.gz -O /tmp/TeamCity-9.1.7.tar.gz
tar -xvf /tmp/TeamCity-9.1.7.tar.gz -C /srv
rm -rf /tmp/TeamCity-9.1.7.tar.gz
mkdir /srv/.BuildServer

# Create user for TeamCity
useradd -m teamcity
chown -R teamcity /srv/TeamCity
chown -R teamcity /srv/.BuildServer

# Added TeamCity server and build agent to systemctl
wget https://gist.github.com/zouxuoz/6079f9153456423fd28c110d2fc9b035/raw/teamcity.service -O /usr/lib/systemd/system/teamcity.service
systemctl start teamcity
systemctl enable teamcity
wget https://gist.github.com/zouxuoz/6079f9153456423fd28c110d2fc9b035/raw/teamcity-build-agent.service -O /usr/lib/systemd/system/teamcity-build-agent.service
systemctl start teamcity-build-agent
systemctl enable teamcity-build-agent

# Install Nginx
yum -y install epel-release
yum -y install nginx
wget https://gist.github.com/zouxuoz/6079f9153456423fd28c110d2fc9b035/raw/teamcity.conf -O /etc/nginx/conf.d/teamcity.conf
systemctl start nginx
systemctl enable nginx

# Install Haveged
yum -y install haveged
systemctl start haveged
systemctl enable haveged

# Install PostgreSQL
yum -y install postgresql-server postgresql-contrib
postgresql-setup initdb
wget https://gist.github.com/zouxuoz/6079f9153456423fd28c110d2fc9b035/raw/pg_hba.conf -O /var/lib/pgsql/data/pg_hba.conf
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Load JDBC driver for TeamCity
wget -P /root/.BuildServer/lib/jdbc/ https://jdbc.postgresql.org/download/postgresql-9.4.1208.jre7.jar

# Create database for TeamCity
su -c 'createdb teamcity' - postgres
su -c 'psql -c "create user teamcity with password '\''teamcity'\'';"' - postgres
su -c 'psql -c "grant all privileges on database teamcity to teamcity;"' - postgres

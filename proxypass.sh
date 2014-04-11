#!/bin/bash
#
# This file is distributed as part of the MariaDB Manager. It is free
# software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation,
# version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright 2014 (c) SkySQL Corporation Ab
#
# Author: Massimo Siani
# Date: April 2014


. $(dirname $0)/libOS.sh
osFamily=$(getOsFamily)


if [[ -f /etc/tomcat6/server.xml ]] ; then
    tomcatConf="/etc/tomcat6/server.xml"
    tomcatService=tomcat6
elif [[ -f /usr/local/tomcat7/conf/server.xml ]] ; then
    tomcatConf="/usr/local/tomcat7/conf/server.xml"
    tomcatService=tomcat7
elif [[ -f /etc/tomcat7/server.xml ]] ; then
    tomcatConf="/etc/tomcat7/server.xml"
    tomcatService=tomcat7
else
    echo "ERROR: tomcat configuration file server.xml not found"
    exit 1
fi
ipaddress=$(hostname)
connector8081="<Connector port=\"8081\" proxyName=\"$ipaddress\" proxyPort=\"80\"\/>"

cat <<EOF1
WARNING: if you are using an Amazon VM, follow these steps:
1. run the script
2. modify the following line in $tomcatConf
   $connector8081
   to contain the public IP or DNS of your Apache machine instead of $ipaddress
3. service $tomcatService restart
EOF1


# Apache for RH and derived
if [[ "x$osFamily" == "xredhat" ]] ; then
    apacheConf="/etc/httpd/conf.d/skysql_rewrite.conf"
    if ! grep -q "/MariaDBManager" $apacheConf ; then
        cat >> $apacheConf <<EOF
ProxyPass /MariaDBManager http://localhost:8081/MariaDBManager
ProxyPassReverse /MariaDBManager http://localhost:8081/MariaDBManager
EOF
        service httpd restart
    fi
elif [[ "x$osFamily" == "xdebian" ]] ; then
    a2enmod rewrite 
    a2enmod proxy_http
    cp -p /etc/apache2/sites-available/default /etc/apache2/sites-available/default_bkp
    cp -p /usr/local/skysql/config/debian_site_template /etc/apache2/sites-available/default
    rm -f /usr/local/skysql/config/debian_site_template
    service apache2 restart
fi

# Tomcat
if ! grep -q "<Connector port=\"8081" $tomcatConf ; then
    sed -i "/Service name=\"Catalina\">/ a $connector8081" $tomcatConf
    service $tomcatService restart
fi

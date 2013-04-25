#!/bin/sh
#
# This file is distributed as part of the SkySQL Database Management Tools for Galera.
#
# It is free software: you can redistribute it and/or modify it under the terms of the
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
# Copyright 2013 SkySQL Ab
# 
dbfile=/usr/local/skysql/SQLite/AdminConsole/admin

if [ ! -f $dbfile ] ; then
	echo Unable to locate the SQLite database, please check our installation
	exit 1
fi
echo
echo Welcome to the SkySQL Database Management Tools for Galera Cluster
echo
echo In order to use the web based interface we must first gather some information
echo on your gluster in order to configure the monitoring tool to gather statistics
echo and allow the status of your cluster to be monitored.
echo
echo We need to access the MySQL instances within your cluster, to do this we require
echo the IP addresses of your nodes and a login and password that may be used to access
echo the database. If you do not already have an account that can be used for this purpose
echo please create a user and password that is able to login and access the information schema
echo of your database.
echo

isnumber()
{
	echo $1 | grep -s '^[0-9][0-9]*$' > /dev/null
	return $?
} 

isIPAddress()
{
	echo $1 | grep -s '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' > /dev/null
	return $?
} 

add_node()
{
	systemid=$1
	nodeid=$2
	state=$3
	username=$4
	passwd=$5
	echo -n "Enter a name for this node: "
	read nodename

	echo -n "Enter a hostname for our server [$nodename]: "
	read hostname
	if [ "$hostname" = "" ] ; then
		hostname=$nodename
	fi

	echo You will now be asked to enter the IP addresses for this node. If the node
	echo has seperate public IP addresses these may be entered. If the node only
	echo has a single IP address then please enter this for both the public and private
	echo addresses.
	DefaultIP=`egrep "[ \t]$hostname([ \t]|\$)" /etc/hosts | awk '{ print $1 }'`

	echo -n "Please enter the private IP address for this node [$DefaultIP]: "
	read privateIP
	if [ "$privateIP" = "" ] ; then
		privateIP=$DefaultIP
	fi
	while ! isIPAddress $privateIP ; do
		echo -n "Invalid IP Address, please re-enter: "
		read privateIP
		if [ "$privateIP" = "" ] ; then
			privateIP=$DefaultIP
		fi
	done

	if [ "$DefaultIP" = "" ] ; then
		DefaultIP=$privateIP
	fi

	echo -n "Please enter the public IP address for this node [$DefaultIP]: "
	read publicIP
	if [ "$publicIP" = "" ] ; then
		publicIP=$DefaultIP
	fi
	while ! isIPAddress $publicIP ; do
		echo -n "Invalid IP Address, please re-enter: "
		read publicIP
		if [ "$publicIP" = "" ] ; then
			publicIP=$DefaultIP
		fi
	done

	# instanceID is really for EC2 instances only, so we will fabricate one for now
	instanceID=node$nodeid

	/usr/bin/php5-cgi index.php 'PUT' "/system/$systemid/node/$nodeid" "name=$nodename&state=$state&hostname=$hostname&publicIP=$publicIP&privateIP=$privateIP&instanceID=$instanceID&username=$username&passwd=$passwd"

}

# Create a new system in the Admin Console database
# We only support a single system currently, so we will give this system an ID of 1
SystemId=1

echo -n "Please enter a name for your new system: "
read SystemName

# Create System and its Properties
/usr/bin/php5-cgi index.php 'PUT' "/system/$SystemId" "name=$SystemName&state=14"
/usr/bin/php5-cgi index.php 'PUT' "/system/$SystemId/property/MONyog" "value=:5555/"
/usr/bin/php5-cgi index.php 'PUT' "/system/$SystemId/property/phpMyAdmin" "/phpmyadmin/index.php"
/usr/bin/php5-cgi index.php 'PUT' "/system/$SystemId/property/MonitorInterval" "60"
/usr/bin/php5-cgi index.php 'PUT' "/system/$SystemId/property/VERSION" "1.2.0 (Galera Cluster)"
/usr/bin/php5-cgi index.php 'PUT' "/system/$SystemId/property/IPMonitor" "false"
# End of System creation

#sqlite3 $dbfile "insert into System values ($SystemId, '$SystemName', datetime('now'), datetime('now'), 14);"
#
#sqlite3 $dbfile "insert into SystemProperties values ($SystemId, 'MONyog', ':5555/');"
#sqlite3 $dbfile "insert into SystemProperties values ($SystemId, 'phpMyAdmin', '/phpmyadmin/index.php');"
#sqlite3 $dbfile "insert into SystemProperties values ($SystemId, 'MonitorInterval', '60');"
#sqlite3 $dbfile "insert into SystemProperties values ($SystemId, 'VERSION', '1.2.0 (Galera Cluster)');"
#sqlite3 $dbfile "insert into SystemProperties values ($SystemId, 'IPMonitor', 'false');"
#
# End of direct inserts
#

echo "Please enter a username on this database that can be used"
echo -n "to gather monitoring data: "
read username
echo -n "Please enter the password for this account: "
read passwd

echo -n "How many nodes are in your Galera cluster: "
read numnodes
isnumber $numnodes
while [ $? -ne 0 ] ; do
	echo -n "Entry must be a number, please re-enter the number of nodes: "
	read numnodes
	isnumber $numnodes
done
i=1
while [ $i -le $numnodes ] ; do
	echo "Enter details for node" $i
	add_node $SystemId $i 100 $username $passwd
	i=`expr $i + 1`
done

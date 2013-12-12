#!/bin/sh
#
# Part of MariaDB Manager package
#
# This file is distributed as part of the SkySQL MariaDB Manager package.
# It is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, version 2.
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
# Copyright 2013-2014 (c) SkySQL Ab
#
# Author      : Massimo Siani
# Version     : 1.0
# Date        : December 2013
# Description    : Generates a new API ID/key pair
#
# parameters    : $1 API ID
# The code below also checks whether a key with the same ID exists
# and, if it does, does not overwrite it.


warnMessage () {
	echo "Key not created, maybe the API is not installed? Please update the file /etc/skysqlmgr/api.ini."
	exit 1
}

if [ $# -lt 1 ]; then
	echo "Component ID not provided. Please provide the component ID. Key not created."
	exit 1
fi


# Generating API key
newKey=$(echo $RANDOM$(date)$RANDOM | md5sum | cut -f1 -d" ")

componentID=$1

# Registering key on components.ini
componentFile=/usr/local/skysql/config/components.ini
keyString="${componentID} = \"${newKey}\""
grep "^${componentID} = \"" ${componentFile} &>/dev/null
if [ "$?" != "0" ] ; then
	echo $keyString >> $componentFile
fi

# Registering key on api.ini
grep "^${componentID} = \"" /etc/skysqlmgr/api.ini &>/dev/null
if [ "$?" != "0" ] ; then
	sed -i "/^\[apikeys\]$/a $keyString" /etc/skysqlmgr/api.ini
	if [ "$?" != "0" ] ; then
		warnMessage
	fi
fi

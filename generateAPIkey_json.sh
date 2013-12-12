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
#		$2 install path
# The code below also checks whether a key with the same ID exists
# and, if it does, does not overwrite it.


if [ $# -lt 2 ]; then
	echo "Component ID not provided. Please provide the component ID. Key not created."
	exit 1
fi


componentID=$1
install_path=$2

# Reading key from components.ini
componentFile=/usr/local/skysql/config/components.ini
uiKey=$(grep "^${componentID} = \"" ${componentFile} | cut -f3 -d" " | tr -d "\"")

# Creating manager.json file
sed -i -e "s/###ID###/$componentID/" \
    -e "s/###CODE###/$uiKey/" \
    ${install_path}config/manager.json

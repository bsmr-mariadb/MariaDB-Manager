#!/bin/bash
#
# Part of MariaDB Manager package
#
# This file is distributed as part of the MariaDB Manager package.
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
# Copyright 2014 (c) SkySQL Corporation Ab
#
# Author      : Massimo Siani
# Date        : May 2014
# Description    : Collects info from the 1.0.1 configuration files and writes the manager.ini

managerDotIniTemplate="/etc/mariadbmanager/manager_template.ini"
apiDotIni="/etc/skysqlmgr/api.ini"
managerDotIni="/etc/mariadbmanager/manager.ini"
managerDotJson="/usr/local/skysql/config/manager.json"

# Already a manager.ini?
[[ -d $(dirname $managerDotIni) && -f $managerDotIni ]] && \
	echo "Found file $(basename $managerDotIni), no changes needed" && exit 0
# No api.ini or manager.json?
[[ ! -d $(dirname $apiDotIni) || ! -f $apiDotIni ]] && \
	echo "No $(basename $apiDotIni) found, cannot create file $(basename $managerDotIni)" && exit 0
[[ ! -d $(dirname $managerDotJson) || ! -f $managerDotJson ]] && \
	echo "No $(basename $managerDotJson) found, cannot create file $(basename $managerDotIni)" && exit 0

currentDir=$(pwd)
cd $(dirname $0)

# Take lines 1 to 128 from the model manager.ini
modelManager=$(head -n 128 $managerDotIniTemplate)

# The whole of the [apikeys] section from api.ini needs to be inserted.
apikeysSection=$(sed -n '/^\[apikeys\]$/,/;/ {/^\[apikeys\]$/n;/;/!p}' $apiDotIni)
escaped=$(sed ':a;N;$!ba;s/\n/\\n/g' <<<"$apikeysSection")
manager=$(sed '/^\[apikeys\]$/a '"$escaped" <<<"$modelManager")

# The value for uri under [apihost] from /usr/local/skysql/config/manager.json
apiuri=$(sed -e 's/.*"uri":"//' -e 's/",.*//' $managerDotJson)
manager=$(sed '/^\[apihost\]$/a '"$apiuri" <<<"$manager")

# Take the whole of api.ini, except the first three lines.
apiini1=$(tail -n +4 $apiDotIni)

# Move the erroremail entry from [logging] to [debug].
erroremail=$(grep erroremail $apiDotIni)
apiini2=$(sed '/^\[debug\]$/a '"$erroremail" <<<"$apiini1")

# Remove the [logging] section
apiini3=$(sed '/^; The logging section/,/^verbose/d' <<<"$apiini2")

# Chop off the [apikeys] section from the end.
apiini4=$(sed '/^; The API keys section/,/^\d =/d' <<<"$apiini3")

# Concatenate the result on to the material from manager.ini.
echo "${manager}" > $managerDotIni
echo "${apiini4}" >> $managerDotIni

cd $currentDir
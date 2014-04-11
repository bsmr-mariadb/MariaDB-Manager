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


getOsFamily () {
    distro_type=""
    release_info=$(cat /etc/*-release)
    if [[ $(echo "$release_info" | grep 'Red Hat') != "" || $(echo "$release_info" | grep 'CentOS') ]]; then
        distro_type="redhat"
    elif [[ $(echo "$release_info" | grep 'Ubuntu') != "" || $(echo "$release_info" | grep 'Debian') ]]; then
        distro_type="debian"
    fi
    echo "$distro_type"
}
export -f getOsFamily

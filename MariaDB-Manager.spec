%define _topdir	 	%(echo $PWD)/
%define name		MariaDB-Manager
%define release		##RELEASE_TAG##
%define version 	##VERSION_TAG##
%define buildroot 	%{_topdir}/%{name}-%{version}-%{release}root
%define install_path	/usr/local/skysql/

BuildRoot:		%{buildroot}
BuildArch:              noarch
Summary: 		MariaDB Manager
License: 		GPL
Name: 			%{name}
Version: 		%{version}
Release: 		%{release}
Source: 		%{name}-%{version}-%{release}.tar.gz
Prefix: 		/
Group: 			Development/Tools
Requires:		MariaDB-Manager-WebUI sqlite MariaDB-Manager-API MariaDB-Manager-Monitor gawk grep coreutils
#BuildRequires:		

%description
MariaDB Manager is a tool to manage and monitor a set of MariaDB
servers using the Galera multi-master replication form Codership.

%prep

%setup -q

%build

%post

# Collect info from api.ini and manager.json, if present
/etc/mariadbmanager/update_manager_ini.sh
# WebUI key for the API
/etc/mariadbmanager/generateAPIkey.sh 1
# API scripts key for the API
/etc/mariadbmanager/generateAPIkey.sh 2
# Monitor key for the API
/etc/mariadbmanager/generateAPIkey.sh 3
# Restart the Monitor so that it reads the new key
/etc/init.d/mariadb-manager-monitor restart

# setup httpd start and restart httpd 
sed -i 's/# chkconfig: -/# chkconfig: 2345/' /etc/init.d/httpd
rm -f /etc/rc{2,3,4,5}.d/K*httpd*
chkconfig --add httpd
/etc/init.d/httpd restart

# Upgrade the API
php /var/www/html/restfulapi/api.php "UPGRADE"
chown -R apache:apache /usr/local/skysql/SQLite

# Cleanup
rm -f /etc/mariadbmanager/generateAPIkey.sh
rm -f /etc/mariadbmanager/manager_template.ini
rm -f /etc/mariadbmanager/update_manager_ini.sh


%install

mkdir -p $RPM_BUILD_ROOT%{install_path}skysql_aws/
mkdir -p $RPM_BUILD_ROOT/etc/mariadbmanager/

cp skysql.config $RPM_BUILD_ROOT%{install_path}skysql_aws/
cp generateAPIkey.sh $RPM_BUILD_ROOT/etc/mariadbmanager/
cp manager_template.ini $RPM_BUILD_ROOT/etc/mariadbmanager/
cp update_manager_ini.sh $RPM_BUILD_ROOT/etc/mariadbmanager/

%clean

%files
%defattr(-,root,root)
%{install_path}skysql_aws/skysql.config
/etc/mariadbmanager/generateAPIkey.sh
/etc/mariadbmanager/manager_template.ini
/etc/mariadbmanager/update_manager_ini.sh

%changelog

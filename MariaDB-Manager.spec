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
Requires:		MariaDB-Manager-WebUI sqlite MariaDB-Manager-API MariaDB-Manager-Monitor tomcat7 gawk grep coreutils
#BuildRequires:		

%description
MariaDB Manager is a tool to manage and monitor a set of MariaDB
servers using the Galera multi-master replication form Codership.

%prep

%setup -q

%build

%post
mkdir -p /usr/local/skysql/SQLite/AdminConsole
chown -R apache:apache %{install_path}SQLite
# mkdir -p /usr/local/skysql/config

sed -i 's/# chkconfig: -/# chkconfig: 2345/' /etc/init.d/httpd
rm -f /etc/rc{2,3,4,5}.d/K*httpd*
chkconfig --add httpd
/etc/init.d/httpd restart

# WebUI key for the API
$RPM_BUILD_ROOT%{install_path}config/generateAPIkey.sh 1
$RPM_BUILD_ROOT%{install_path}config/generateAPIkey_json.sh 1 %{install_path}
# Monitor key for the API
$RPM_BUILD_ROOT%{install_path}config/generateAPIkey.sh 3
# Restart the Monitor so that it reads the new key
/etc/init.d/mariadb-enterprise-monitor restart

# Cleanup
rm -f $RPM_BUILD_ROOT%{install_path}config/generateAPIkey*.sh


%install

mkdir -p $RPM_BUILD_ROOT%{install_path}
mkdir -p $RPM_BUILD_ROOT%{install_path}config
mkdir -p $RPM_BUILD_ROOT%{install_path}skysql_aws/

cp manager.json $RPM_BUILD_ROOT%{install_path}config/
cp skysql.config $RPM_BUILD_ROOT%{install_path}skysql_aws/
cp generateAPIkey*.sh $RPM_BUILD_ROOT%{install_path}config/

%clean

%files
%defattr(-,root,root)
%{install_path}config/manager.json
%{install_path}skysql_aws/skysql.config
%{install_path}config/generateAPIkey*.sh

%changelog

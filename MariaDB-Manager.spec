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
Requires:		MariaDB-Manager-WebUI sqlite MariaDB-Manager-API MariaDB-Manager-Monitor tomcat7 = 7.0.39-1 gawk grep coreutils
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
mkdir -p /usr/local/skysql/config

sed -i 's/# chkconfig: -/# chkconfig: 2345/' /etc/init.d/httpd
rm -f /etc/rc{2,3,4,5}.d/K*httpd*
chkconfig --add httpd
/etc/init.d/httpd restart

cp generateAPIkey*.sh /usr/local/skysql/config/
# WebUI key for the API
/usr/local/skysql/config/generateAPIkey.sh 2
/usr/local/skysql/config/generateAPIkey_json.sh 2
# Monitor key for the API
/usr/local/skysql/config/generateAPIkey.sh 3
# Restart the Monitor so that it reads the new key
/etc/init.d/mariadb-enterprise-monitor restart

# Cleanup
/usr/local/skysql/config/generateAPIkey.sh 3


%install

mkdir -p $RPM_BUILD_ROOT%{install_path}
mkdir $RPM_BUILD_ROOT%{install_path}config
mkdir $RPM_BUILD_ROOT%{install_path}skysql_aws/

cp manager.json $RPM_BUILD_ROOT%{install_path}config/manager.json.template
cp skysql.config $RPM_BUILD_ROOT%{install_path}skysql_aws/

%clean

%files
%defattr(-,root,root)
%{install_path}config/manager.json
%{install_path}skysql_aws/skysql.config

%changelog

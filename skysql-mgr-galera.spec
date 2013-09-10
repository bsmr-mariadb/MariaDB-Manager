%define _topdir	 	%(echo $PWD)/
%define name		skysql-mgr-galera
%define release		##RELEASE_TAG##
%define version 	##VERSION_TAG##
%define buildroot 	%{_topdir}/%{name}-%{version}-%{release}root
%define install_path	/usr/local/skysql/

BuildRoot:		%{buildroot}
Summary: 		SkySQL Cloud Data Suite
License: 		GPL
Name: 			%{name}
Version: 		%{version}
Release: 		%{release}
Source: 		%{name}-%{version}-%{release}.tar.gz
Prefix: 		/
Group: 			Development/Tools
Requires:		skysql-manager sqlite admin_php skysql_monitor

#BuildRequires:		

%description
Metapackage to install SkySQL рackages for MariaDB+Galera

%prep

%setup -q

%build

%post
#if [ ! -f %{install_path}SQLite/AdminConsole/admin ]; then
#	%{install_path}skysql_aws/admin_schema
#	%{install_path}skysql_aws/admin_schema.Galera
#	chown -R apache:apache %{install_path}SQLite
#fi

%install

mkdir -p $RPM_BUILD_ROOT%{install_path}
mkdir $RPM_BUILD_ROOT%{install_path}config
mkdir $RPM_BUILD_ROOT%{install_path}skysql_aws/

cp CreateSystem.sh $RPM_BUILD_ROOT%{install_path}
cp manager.json $RPM_BUILD_ROOT%{install_path}config/
cp skysql.config $RPM_BUILD_ROOT%{install_path}skysql_aws/

%clean


%files
%defattr(-,root,root)
%{install_path}CreateSystem.sh
%{install_path}config/manager.json
%{install_path}skysql_aws/skysql.config


%changelog

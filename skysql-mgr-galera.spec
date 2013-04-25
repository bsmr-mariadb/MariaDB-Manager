%define _topdir	 	%(echo $PWD)/
%define name		skysql-mgr-galera
%define release		1
%define version 	0.1
%define buildroot %{_topdir}/%{name}-%{version}-%{release}root
%define install_path	/usr/local/skysql/

BuildRoot:	%{buildroot}
Summary: 		SkySQL Cloud Data Suite
License: 		GPL
Name: 			%{name}
Version: 		%{version}
Release: 		%{release}
Source: 		%{name}-%{version}-%{release}.tar.gz
Prefix: 		/
Group: 			Development/Tools
Requires:		httpd24 admin_ui sqlite php54-pdo phpMyAdmin MariaDB-client MariaDB-server MariaDB-compat MariaDB-shared admin_schema admin_php pcs

# glusterfs is installed by glusterfs-server
# httpd is installed by php
#BuildRequires:		

%description
Metapackage to install SkySQL рackages

%prep

%setup -q

%build

%post
%{install_path}skysql_aws/admin_schema
%{install_path}skysql_aws/admin_schema.Galera

%install

mkdir -p $RPM_BUILD_ROOT%{install_path}
cp CreateSystem.sh $RPM_BUILD_ROOT%{install_path}


%clean


%files
%defattr(-,root,root)
%{install_path}CreateSystem.sh

%changelog

%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define release %{rpm_release}%{?dist}

Summary: Ruby PDNS Pipe Backend Framework
Name: ruby-pdns
Version: %{version}
Release: %{release}
Group: System Tools
License: GPL
URL: http://code.google.com/p/ruby-pdns/
Source0: %{name}-%{version}-%{rpm_release}.tgz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: ruby ruby-net-geoip pdns GeoIP GeoIP-data
BuildArch: noarch
Packager: R.I.Pienaar <rip@devco.net>

%description
A framework for hosting PDNS pipe backends, allows for simple locks of code to run
without having to worry about the details of integrating into PDNS etc.

%prep
%setup -q -n %{name}-%{version}-%{rpm_release}

%build 

%install
rm -rf %{buildroot}
%{__install} -d -m0755  %{buildroot}/%{ruby_sitelib}/pdns
%{__install} -d -m0755  %{buildroot}/etc/pdns/records
%{__install} -d -m0755  %{buildroot}/etc/cron.d
%{__install} -d -m0755  %{buildroot}/usr/sbin
%{__install} -d -m0755  %{buildroot}/var/log/pdns
%{__install} -d -m0755  %{buildroot}/var/log/pdns/stats
%{__install} -m0755 sbin/pdns-pipe-runner.rb %{buildroot}/usr/sbin/pdns-pipe-runner.rb
%{__install} -m0755 sbin/pdns-pipe-tester.rb %{buildroot}/usr/sbin/pdns-pipe-tester.rb
%{__install} -m0755 sbin/pdns-aggregate-stats.rb %{buildroot}/usr/sbin/pdns-aggregate-stats.rb
%{__install} -m0644 etc/rubypdns.cron %{buildroot}/etc/cron.d/rubypdns
cp -R lib/pdns.rb %{buildroot}/%{ruby_sitelib}/
cp -R lib/pdns/* %{buildroot}/%{ruby_sitelib}/pdns/
cp etc/pdns-ruby-backend-dist.cfg %{buildroot}/etc/pdns/pdns-ruby-backend.cfg
cp -R records/*sample %{buildroot}/etc/pdns/records

%clean
rm -rf %{buildroot}

%files
%{ruby_sitelib}/pdns.rb
%{ruby_sitelib}/pdns
%config(noreplace) /etc/pdns/pdns-ruby-backend.cfg
%config /etc/pdns/records
%config /etc/cron.d/rubypdns
/usr/sbin/pdns-pipe-runner.rb
/usr/sbin/pdns-pipe-tester.rb
%defattr(0755,pdns,pdns,0755)
/var/log/pdns
/var/log/pdns/stats

%changelog
* Tue Aug 11 2009 R.I.Pienaar <rip@devco.net> - 0.4
- Add pdns-pipe-tester.rb

* Thu Aug 02 2009 R.I.Pienaar <rip@devco.net> - 0.1
- First release

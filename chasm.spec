Name:           chasm
Version:        1.0.0
Release:        1%{?dist}
Summary:        Chasm - Ansible-based Infrastructure Management

License:        MIT
URL:            https://github.com/RA-Rob/chasm
BuildArch:      noarch

# Common requirements for both RHEL and Rocky
Requires:       ansible >= 2.9
Requires:       python3 >= 3.9
Requires:       python3-pip
Requires:       python3-setuptools

# Docker requirements
Requires:       container-selinux
Requires:       device-mapper-persistent-data
Requires:       lvm2

%description
Chasm is an Ansible-based infrastructure management system that provides automated deployment and configuration capabilities.

%prep
%setup -q -n chasm-%{version}

%build
# No build step needed for Ansible playbooks

%install
# Install playbooks and roles
mkdir -p %{buildroot}%{_datadir}/chasm
cp -r playbooks roles inventory group_vars host_vars %{buildroot}%{_datadir}/chasm/
cp site.yml %{buildroot}%{_datadir}/chasm/
cp ansible.cfg %{buildroot}%{_datadir}/chasm/

# Create symlink for easy access
mkdir -p %{buildroot}%{_bindir}
ln -s %{_datadir}/chasm/site.yml %{buildroot}%{_bindir}/chasm

%files
%{_datadir}/chasm/
%{_bindir}/chasm

%changelog
* %(date "+%a %b %d %Y") %{packager} - %{version}-%{release}
- Initial release 
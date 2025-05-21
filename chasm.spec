Name:           chasm
Version:        1.0.0
Release:        1%{?dist}
Summary:        Chasm - Ansible-based Infrastructure Management

License:        MIT
URL:            https://github.com/RA-Rob/chasm
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

# Common requirements for both RHEL and Rocky
Requires:       ansible-core >= 2.9
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
mkdir -p %{buildroot}%{_bindir}

# Copy directories if they exist
[ -d playbooks ] && cp -r playbooks %{buildroot}%{_datadir}/chasm/
[ -d roles ] && cp -r roles %{buildroot}%{_datadir}/chasm/
[ -d inventory ] && cp -r inventory %{buildroot}%{_datadir}/chasm/
[ -d group_vars ] && cp -r group_vars %{buildroot}%{_datadir}/chasm/
[ -d host_vars ] && cp -r host_vars %{buildroot}%{_datadir}/chasm/

# Copy individual files if they exist
[ -f site.yml ] && cp site.yml %{buildroot}%{_datadir}/chasm/
[ -f ansible.cfg ] && cp ansible.cfg %{buildroot}%{_datadir}/chasm/

# Create wrapper script
cat > %{buildroot}%{_bindir}/chasm << 'EOF'
#!/bin/bash
ansible-playbook /usr/share/chasm/site.yml "$@"
EOF

# Make wrapper script executable
chmod +x %{buildroot}%{_bindir}/chasm

%files
%{_datadir}/chasm/
%{_bindir}/chasm

%changelog
* %(date "+%a %b %d %Y") %{packager} - %{version}-%{release}
- Initial release 
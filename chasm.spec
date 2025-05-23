Name:           chasm
Version:        0.0.1
Release:        0.rc1%{?dist}
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
%setup -q -n %{name}-%{version}

%build
# No build step needed for Ansible playbooks

%install
# Create necessary directories
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/chasm
mkdir -p %{buildroot}%{_datadir}/chasm/playbooks
mkdir -p %{buildroot}%{_datadir}/chasm/roles
mkdir -p %{buildroot}%{_datadir}/chasm/inventory
mkdir -p %{buildroot}%{_datadir}/chasm/tools

# Install the main chasm script
install -m 755 tools/chasm %{buildroot}%{_bindir}/chasm

# Install playbooks
cp -r playbooks/* %{buildroot}%{_datadir}/chasm/playbooks/

# Install roles
cp -r roles/* %{buildroot}%{_datadir}/chasm/roles/

# Install inventory
cp -r inventory/* %{buildroot}%{_datadir}/chasm/inventory/

# Install tools
cp -r tools/* %{buildroot}%{_datadir}/chasm/tools/

# Create ansible.cfg
cat > %{buildroot}%{_datadir}/chasm/ansible.cfg << 'EOF'
[defaults]
inventory = %{_datadir}/chasm/inventory
roles_path = %{_datadir}/chasm/roles
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
bin_ansible_callbacks = True
EOF

# Create host_vars directory
mkdir -p %{buildroot}%{_datadir}/chasm/inventory/host_vars

# Create group_vars directory
mkdir -p %{buildroot}%{_datadir}/chasm/inventory/group_vars

# Create playbooks directory
mkdir -p %{buildroot}%{_datadir}/chasm/playbooks

# Create roles directory
mkdir -p %{buildroot}%{_datadir}/chasm/roles

# Create tools directory
mkdir -p %{buildroot}%{_datadir}/chasm/tools

%files
%{_datadir}/chasm/
%{_bindir}/chasm

%changelog
* %(date "+%a %b %d %Y") %{packager} - %{version}-%{release}
- Initial release 
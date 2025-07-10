Name:           rift
Version:        0.0.1
Release:        0.rc1%{?dist}
Summary:        Rift - Ansible-based Infrastructure Management

License:        MIT
URL:            https://github.com/RA-Rob/rift
Source0:        %{name}-%{version}.tar.gz
Source1:        requirements.txt
BuildArch:      noarch

# Define conditionals
%define _with_rocky9_tools %(if [ -f %{buildroot}%{_datadir}/rift/.rocky9_tools_installed ]; then echo 1; else echo 0; fi)

# Common requirements
Requires:       ansible-core >= 2.9
Requires:       python3 >= 3.9
Requires:       python3-pip
Requires:       python3-setuptools

# Documentation build requirements
BuildRequires:  python3
BuildRequires:  python3-pip

# Docker requirements
Requires:       container-selinux
Requires:       device-mapper-persistent-data
Requires:       lvm2

# Cloud provider requirements (optional)
Suggests:       awscli
Suggests:       azure-cli

# VM management requirements
Requires:       libvirt-client
Requires:       qemu-kvm
Requires:       virt-install

%description
Rift is an Ansible-based infrastructure management system that provides automated deployment and configuration capabilities.
It includes tools for managing VMs across multiple platforms including KVM, AWS, and Azure.

The following commands are available:
- rift vm-create: Create VMs on KVM, AWS, or Azure
- rift vm-cleanup: Clean up VMs and associated resources
- rift vm-test: Test VM connectivity and configuration

Note: AWS and Azure CLI tools are optional dependencies. Install them separately if you need cloud provider support.

For detailed documentation, see %{_docdir}/%{name}/vm-management.rst

%prep
%setup -q -n %{name}-%{version}

%build
# Install Python build dependencies
pip3 install sphinx sphinx-rtd-theme

# Build documentation
cd docs
make html
cd ..

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libexecdir}/rift/commands
mkdir -p %{buildroot}%{_datadir}/rift
mkdir -p %{buildroot}%{_datadir}/rift/playbooks
mkdir -p %{buildroot}%{_datadir}/rift/roles
mkdir -p %{buildroot}%{_datadir}/rift/inventory
mkdir -p %{buildroot}%{_datadir}/rift/tools
mkdir -p %{buildroot}%{_datadir}/rift/tools/rocky9
mkdir -p %{buildroot}%{_docdir}/%{name}
mkdir -p %{buildroot}%{_docdir}/%{name}/html

# Install VERSION file
install -m 644 VERSION %{buildroot}%{_datadir}/rift/VERSION

# Install documentation
install -m 644 docs/vm-management.rst %{buildroot}%{_docdir}/%{name}/vm-management.rst
install -m 644 docs/dashboard-management.md %{buildroot}%{_docdir}/%{name}/dashboard-management.md
cp -r docs/_build/html/* %{buildroot}%{_docdir}/%{name}/html/

# Install the main rift script
install -m 755 tools/rift %{buildroot}%{_bindir}/rift

# Install command scripts
install -m 755 tools/commands/*.sh %{buildroot}%{_libexecdir}/rift/commands/

# Install playbooks, roles, and inventory
cp -r playbooks/* %{buildroot}%{_datadir}/rift/playbooks/
cp -r roles/* %{buildroot}%{_datadir}/rift/roles/
cp -r inventory/* %{buildroot}%{_datadir}/rift/inventory/

# Install tools
cp tools/[!c]*.sh %{buildroot}%{_datadir}/rift/tools/ 2>/dev/null || :

# Install Rocky9Ansible tools if present
mkdir -p %{buildroot}%{_datadir}/rift/tools/rocky9
if [ -d "Rocky9Ansible/tools" ] && ls Rocky9Ansible/tools/*.sh >/dev/null 2>&1; then
    cp Rocky9Ansible/tools/*.sh %{buildroot}%{_datadir}/rift/tools/rocky9/
    touch %{buildroot}%{_datadir}/rift/.rocky9_tools_installed
fi

# Create ansible.cfg
cat > %{buildroot}%{_datadir}/rift/ansible.cfg << 'EOF'
[defaults]
inventory = %{_datadir}/rift/inventory
roles_path = %{_datadir}/rift/roles
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
bin_ansible_callbacks = True
EOF

# Create inventory directories
mkdir -p %{buildroot}%{_datadir}/rift/inventory/host_vars
mkdir -p %{buildroot}%{_datadir}/rift/inventory/group_vars

# Create dashboards directory and install dashboard files
mkdir -p %{buildroot}%{_datadir}/rift/dashboards
# Install all JSON files from dashboards directory
if ls dashboards/*.json >/dev/null 2>&1; then
    cp dashboards/*.json %{buildroot}%{_datadir}/rift/dashboards/
fi

%files
%doc README.md
%doc %{_docdir}/%{name}/vm-management.rst
%doc %{_docdir}/%{name}/dashboard-management.md
%doc %{_docdir}/%{name}/html/
%{_datadir}/rift/
%{_bindir}/rift
%{_libexecdir}/rift/
%attr(755,root,root) %{_libexecdir}/rift/commands/*.sh
%attr(755,root,root) %{_datadir}/rift/tools/*.sh
%dir %{_datadir}/rift/tools/rocky9
%if 0%{?_with_rocky9_tools}
%attr(755,root,root) %{_datadir}/rift/tools/rocky9/*.sh
%endif

%changelog
* %(date "+%a %b %d %Y") %{packager} - %{version}-%{release}
- Added comprehensive VM management documentation
- Added VM management wrapper scripts (vm-create, vm-cleanup, vm-test)
- Added Rocky9Ansible tools for multi-platform VM management
- Added cloud provider and VM management dependencies
- Added explicit file permissions for wrapper scripts
- Initial release 
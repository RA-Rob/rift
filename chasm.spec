Name:           chasm
Version:        0.0.1
Release:        0.rc1%{?dist}
Summary:        Chasm - Ansible-based Infrastructure Management

License:        MIT
URL:            https://github.com/RA-Rob/chasm
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

# Define conditionals
%define _with_rocky9_tools %(if [ -f %{buildroot}%{_datadir}/chasm/.rocky9_tools_installed ]; then echo 1; else echo 0; fi)

# Common requirements
Requires:       ansible-core >= 2.9
Requires:       python3 >= 3.9
Requires:       python3-pip
Requires:       python3-setuptools

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
Chasm is an Ansible-based infrastructure management system that provides automated deployment and configuration capabilities.
It includes tools for managing VMs across multiple platforms including KVM, AWS, and Azure.

The following commands are available:
- chasm vm-create: Create VMs on KVM, AWS, or Azure
- chasm vm-cleanup: Clean up VMs and associated resources
- chasm vm-test: Test VM connectivity and configuration

Note: AWS and Azure CLI tools are optional dependencies. Install them separately if you need cloud provider support.

For detailed documentation, see %{_docdir}/%{name}/vm-management.md

%prep
%setup -q -n %{name}-%{version}

%build
# No build step needed for Ansible playbooks

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libexecdir}/chasm/commands
mkdir -p %{buildroot}%{_datadir}/chasm
mkdir -p %{buildroot}%{_datadir}/chasm/playbooks
mkdir -p %{buildroot}%{_datadir}/chasm/roles
mkdir -p %{buildroot}%{_datadir}/chasm/inventory
mkdir -p %{buildroot}%{_datadir}/chasm/tools
mkdir -p %{buildroot}%{_datadir}/chasm/tools/rocky9
mkdir -p %{buildroot}%{_docdir}/%{name}

# Install VERSION file
install -m 644 VERSION %{buildroot}%{_datadir}/chasm/VERSION

# Install documentation
install -m 644 docs/vm-management.md %{buildroot}%{_docdir}/%{name}/vm-management.md

# Install the main chasm script
install -m 755 tools/chasm %{buildroot}%{_bindir}/chasm

# Install command scripts
install -m 755 tools/commands/*.sh %{buildroot}%{_libexecdir}/chasm/commands/

# Install playbooks, roles, and inventory
cp -r playbooks/* %{buildroot}%{_datadir}/chasm/playbooks/
cp -r roles/* %{buildroot}%{_datadir}/chasm/roles/
cp -r inventory/* %{buildroot}%{_datadir}/chasm/inventory/

# Install tools
cp tools/[!c]*.sh %{buildroot}%{_datadir}/chasm/tools/ 2>/dev/null || :

# Install Rocky9Ansible tools if present
mkdir -p %{buildroot}%{_datadir}/chasm/tools/rocky9
if [ -d "Rocky9Ansible/tools" ] && ls Rocky9Ansible/tools/*.sh >/dev/null 2>&1; then
    cp Rocky9Ansible/tools/*.sh %{buildroot}%{_datadir}/chasm/tools/rocky9/
    touch %{buildroot}%{_datadir}/chasm/.rocky9_tools_installed
fi

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

# Create inventory directories
mkdir -p %{buildroot}%{_datadir}/chasm/inventory/host_vars
mkdir -p %{buildroot}%{_datadir}/chasm/inventory/group_vars

%files
%doc README.md
%doc %{_docdir}/%{name}/vm-management.md
%{_datadir}/chasm/
%{_bindir}/chasm
%{_libexecdir}/chasm/
%attr(755,root,root) %{_libexecdir}/chasm/commands/*.sh
%attr(755,root,root) %{_datadir}/chasm/tools/*.sh
%dir %{_datadir}/chasm/tools/rocky9
%if 0%{?_with_rocky9_tools}
%attr(755,root,root) %{_datadir}/chasm/tools/rocky9/*.sh
%endif

%changelog
* %(date "+%a %b %d %Y") %{packager} - %{version}-%{release}
- Added comprehensive VM management documentation
- Added VM management wrapper scripts (vm-create, vm-cleanup, vm-test)
- Added Rocky9Ansible tools for multi-platform VM management
- Added cloud provider and VM management dependencies
- Added explicit file permissions for wrapper scripts
- Initial release 
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

# Cloud provider requirements
Requires:       awscli
Requires:       azure-cli

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

For detailed documentation, see %{_docdir}/%{name}/vm-management.md

%prep
%setup -q -n %{name}-%{version}

%build
# No build step needed for Ansible playbooks

%install
# Create necessary directories
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

# Install playbooks
cp -r playbooks/* %{buildroot}%{_datadir}/chasm/playbooks/

# Install roles
cp -r roles/* %{buildroot}%{_datadir}/chasm/roles/

# Install inventory
cp -r inventory/* %{buildroot}%{_datadir}/chasm/inventory/

# Install tools (excluding main script and commands)
find tools -type f -not -name 'chasm' -not -path 'tools/commands/*' -exec cp {} %{buildroot}%{_datadir}/chasm/tools/ \;

# Install Rocky9Ansible tools if available
if [ -d "Rocky9Ansible/tools" ]; then
    cp -r Rocky9Ansible/tools/*.sh %{buildroot}%{_datadir}/chasm/tools/rocky9/ || :
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

# Create host_vars directory
mkdir -p %{buildroot}%{_datadir}/chasm/inventory/host_vars

# Create group_vars directory
mkdir -p %{buildroot}%{_datadir}/chasm/inventory/group_vars

%files
%doc README.md
%doc %{_docdir}/%{name}/vm-management.md
%license LICENSE
%{_datadir}/chasm/
%{_bindir}/chasm
%{_libexecdir}/chasm/
%attr(755,root,root) %{_libexecdir}/chasm/commands/vm-*.sh
%attr(755,root,root) %{_datadir}/chasm/tools/rocky9/*.sh

%changelog
* %(date "+%a %b %d %Y") %{packager} - %{version}-%{release}
- Added comprehensive VM management documentation
- Added VM management wrapper scripts (vm-create, vm-cleanup, vm-test)
- Added Rocky9Ansible tools for multi-platform VM management
- Added cloud provider and VM management dependencies
- Added explicit file permissions for wrapper scripts
- Initial release 
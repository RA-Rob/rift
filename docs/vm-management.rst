VM Management
============

This section describes the VM management commands available in Rift. These commands provide a unified interface for managing virtual machines across multiple platforms including KVM, AWS, and Azure.

Available Commands
----------------

vm-create
~~~~~~~~~

Creates virtual machines on the specified platform.

.. code-block:: bash

   rift vm-create [OPTIONS] <platform>

Options
^^^^^^^

* ``-h, --help``: Show help message
* ``-f, --force``: Force recreation of VMs if they exist
* ``-c, --config``: Path to custom configuration file

Platforms
^^^^^^^^

* ``kvm``: Create VMs using local KVM/libvirt
* ``aws``: Create VMs on AWS
* ``azure``: Create VMs on Azure

Examples
^^^^^^^^

.. code-block:: bash

   # Create VMs on AWS
   rift vm-create aws

   # Force recreate KVM VMs
   rift vm-create --force kvm

   # Create Azure VMs with custom config
   rift vm-create -c my-config.conf azure

vm-cleanup
~~~~~~~~~

Cleans up VMs and associated resources on the specified platform.

.. code-block:: bash

   rift vm-cleanup [OPTIONS] <platform>

Options
^^^^^^^

* ``-h, --help``: Show help message
* ``-f, --force``: Skip confirmation prompts
* ``-c, --config``: Path to custom configuration file

Platforms
^^^^^^^^

* ``kvm``: Clean up local KVM/libvirt VMs
* ``aws``: Clean up AWS resources
* ``azure``: Clean up Azure resources

Examples
^^^^^^^^

.. code-block:: bash

   # Clean up AWS resources
   rift vm-cleanup aws

   # Force cleanup Azure resources
   rift vm-cleanup --force azure

   # Clean up KVM VMs with custom config
   rift vm-cleanup -c my-config.conf kvm

vm-test
~~~~~~~

Tests VM connectivity and configuration.

.. code-block:: bash

   rift vm-test [OPTIONS]

Options
^^^^^^^

* ``-h, --help``: Show help message
* ``-v, --verbose``: Show detailed test output

Examples
^^^^^^^^

.. code-block:: bash

   # Run basic tests
   rift vm-test

   # Run tests with detailed output
   rift vm-test --verbose

Configuration Files
-----------------

Configuration files are JSON or YAML files that specify VM settings. Here's an example configuration:

.. code-block:: yaml

   vms:
     controller:
       cpus: 2
       memory: 4096
       disk: 20G
     worker1:
       cpus: 2
       memory: 4096
       disk: 20G
     worker2:
       cpus: 2
       memory: 4096
       disk: 20G

   network:
     type: nat
     domain: lab.local

   cloud:
     aws:
       region: us-east-1
       instance_type: t3.medium
     azure:
       location: eastus
       vm_size: Standard_B2s

Platform-Specific Details
-----------------------

KVM
~~~

* Uses local KVM/libvirt for virtualization
* VMs are created with cloud-init support
* Default network is NAT (192.168.122.0/24)
* Requires root/sudo access

AWS
~~~

* Uses EC2 instances
* Requires configured AWS CLI credentials
* Creates necessary VPC, subnets, and security groups
* Uses Rocky Linux 9 AMIs

Azure
~~~~~

* Uses Azure VMs
* Requires configured Azure CLI credentials
* Creates resource group and networking components
* Uses RHEL 9 images (Rocky Linux compatible)

Troubleshooting
-------------

Common Issues
~~~~~~~~~~~~

1. Permission Denied
   ^^^^^^^^^^^^^^^^

   .. code-block:: bash

      # Fix KVM permissions
      sudo usermod -aG libvirt,kvm $USER

2. Network Not Available
   ^^^^^^^^^^^^^^^^^^^^^

   .. code-block:: bash

      # Start default network
      sudo virsh net-start default
      sudo virsh net-autostart default

3. Cloud Provider Authentication
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   .. code-block:: bash

      # Configure AWS
      aws configure

      # Configure Azure
      az login

Log Locations
~~~~~~~~~~~~

* KVM: ``/var/log/libvirt/qemu/``
* Cloud-init: ``/var/log/cloud-init*.log``
* System: ``journalctl -u libvirtd``

Best Practices
------------

1. Resource Cleanup
   ^^^^^^^^^^^^^^^

   * Always clean up cloud resources when done
   * Use ``--force`` with caution
   * Verify resource deletion in cloud console

2. Configuration Management
   ^^^^^^^^^^^^^^^^^^^^^^^

   * Use version-controlled config files
   * Keep sensitive data in separate files
   * Use environment-specific configs

3. Testing
   ^^^^^^^

   * Run ``vm-test`` after creation
   * Check connectivity between VMs
   * Verify application deployment 
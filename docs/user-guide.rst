User Guide
=========

Command Line Interface
--------------------

The ``chasm`` command provides several subcommands for managing your infrastructure:

.. code-block:: bash

   chasm --help

Common Commands
~~~~~~~~~~~~~

init
^^^^

Initialize a new Chasm project:

.. code-block:: bash

   chasm init [project-name]

inventory
^^^^^^^^

Manage your inventory:

.. code-block:: bash

   chasm inventory create    # Create a new inventory
   chasm inventory list     # List available inventories
   chasm inventory show     # Show inventory details

deploy
^^^^^^

Deploy your infrastructure:

.. code-block:: bash

   chasm deploy             # Deploy all playbooks
   chasm deploy --playbook  # Deploy specific playbook

Configuration
------------

Project Configuration
~~~~~~~~~~~~~~~~~~~

The project configuration file (``chasm.yml``) supports the following options:

.. code-block:: yaml

   # Global settings
   ansible_config: ansible.cfg
   inventory_dir: inventory
   playbook_dir: playbooks
   role_dir: roles

   # Default variables
   variables:
     environment: production
     region: us-west-2

Inventory Management
------------------

Creating an Inventory
~~~~~~~~~~~~~~~~~~~

1. Create a new inventory:

   .. code-block:: bash

      chasm inventory create my-inventory

2. Edit the inventory file:

   .. code-block:: yaml

      all:
        children:
          webservers:
            hosts:
              web1:
                ansible_host: 192.168.1.10
              web2:
                ansible_host: 192.168.1.11
          databases:
            hosts:
              db1:
                ansible_host: 192.168.1.20

Playbook Management
-----------------

Creating a Playbook
~~~~~~~~~~~~~~~~~

1. Create a new playbook:

   .. code-block:: bash

      chasm playbook create my-playbook

2. Edit the playbook:

   .. code-block:: yaml

      - name: My Playbook
        hosts: webservers
        become: yes
        tasks:
          - name: Install nginx
            package:
              name: nginx
              state: present

Role Management
-------------

Creating a Role
~~~~~~~~~~~~~

1. Create a new role:

   .. code-block:: bash

      chasm role create my-role

2. The role structure will be created in the ``roles/`` directory.

Best Practices
------------

* Keep your inventory organized using groups
* Use variables for configuration
* Document your playbooks and roles
* Use version control for your project
* Test your playbooks before deployment 
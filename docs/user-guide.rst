User Guide
=========

Command Line Interface
--------------------

The ``rift`` command provides several subcommands for managing your infrastructure:

.. code-block:: bash

   rift --help

Common Commands
~~~~~~~~~~~~~

init
^^^^

Initialize a new Rift project:

.. code-block:: bash

   rift init [project-name]

inventory
^^^^^^^^

Manage your inventory:

.. code-block:: bash

   rift inventory create    # Create a new inventory
   rift inventory list     # List available inventories
   rift inventory show     # Show inventory details

deploy
^^^^^^

Deploy your infrastructure:

.. code-block:: bash

   rift deploy             # Deploy all playbooks
   rift deploy --playbook  # Deploy specific playbook

Configuration
------------

Project Configuration
~~~~~~~~~~~~~~~~~~~

The project configuration file (``rift.yml``) supports the following options:

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

      rift inventory create my-inventory

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

      rift playbook create my-playbook

2. Edit the playbook:

   .. code-block:: yaml

      ---
      - name: Deploy application
        hosts: webservers
        tasks:
          - name: Install nginx
            package:
              name: nginx
              state: present

Role Management
--------------

Creating a Role
~~~~~~~~~~~~

1. Create a new role:

   .. code-block:: bash

      rift role create my-role

2. Edit the role tasks:

   .. code-block:: yaml

      ---
      - name: Install packages
        package:
          name: "{{ item }}"
          state: present
        loop:
          - nginx
          - php-fpm

Best Practices
--------------

1. **Version Control**: Always use version control for your playbooks and roles
2. **Testing**: Test your playbooks in a staging environment before production
3. **Documentation**: Document your roles and playbooks
4. **Security**: Use encrypted variables for sensitive data
5. **Modularity**: Break down complex tasks into smaller, reusable roles

Advanced Usage
--------------

Custom Modules
~~~~~~~~~~~~~

You can create custom modules for Rift:

.. code-block:: python

   # modules/my_module.py
   from ansible.module_utils.basic import AnsibleModule

   def main():
       module = AnsibleModule(
           argument_spec=dict(
               name=dict(type='str', required=True),
               state=dict(type='str', default='present')
           )
       )
       # Module implementation
       module.exit_json(changed=True, msg='Success')

   if __name__ == '__main__':
       main()

Plugins
~~~~~~~

Rift supports custom plugins for extending functionality:

.. code-block:: python

   # plugins/filter_plugins/my_filters.py
   def my_filter(value):
       return value.upper()

   class FilterModule(object):
       def filters(self):
           return {
               'my_filter': my_filter
           } 
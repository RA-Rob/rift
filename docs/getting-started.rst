Getting Started
==============

Quick Start
----------

1. Initialize a new Rift project:

   .. code-block:: bash

      rift init my-project
      cd my-project

2. Configure your inventory:

   .. code-block:: bash

      rift inventory create

3. Run your first deployment:

   .. code-block:: bash

      rift deploy

Basic Concepts
-------------

Inventory
~~~~~~~~

The inventory defines the hosts and groups that Rift will manage. It's stored in the ``inventory/`` directory.

Playbooks
~~~~~~~~

Playbooks are Ansible playbooks that define the tasks to be executed. They are stored in the ``playbooks/`` directory.

Roles
~~~~~

Roles are reusable components that can be shared across playbooks. They are stored in the ``roles/`` directory.

Configuration
~~~~~~~~~~~~

The main configuration file is ``rift.yml`` in your project root. It defines global settings and variables.

Next Steps
---------

* Read the :doc:`user-guide` for detailed usage instructions
* Check the :doc:`api-reference` for API documentation
* Learn about :doc:`development` for contributing to Rift 
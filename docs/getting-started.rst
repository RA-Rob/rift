Getting Started
==============

Quick Start
----------

1. Initialize a new Chasm project:

   .. code-block:: bash

      chasm init my-project
      cd my-project

2. Configure your inventory:

   .. code-block:: bash

      chasm inventory create

3. Run your first deployment:

   .. code-block:: bash

      chasm deploy

Basic Concepts
-------------

Inventory
~~~~~~~~

The inventory defines the hosts and groups that Chasm will manage. It's stored in the ``inventory/`` directory.

Playbooks
~~~~~~~~

Playbooks are Ansible playbooks that define the tasks to be executed. They are stored in the ``playbooks/`` directory.

Roles
~~~~~

Roles are reusable components that can be shared across playbooks. They are stored in the ``roles/`` directory.

Configuration
~~~~~~~~~~~~

The main configuration file is ``chasm.yml`` in your project root. It defines global settings and variables.

Next Steps
---------

* Read the :doc:`user-guide` for detailed usage instructions
* Check the :doc:`api-reference` for API documentation
* Learn about :doc:`development` for contributing to Chasm 
Installation
============

Requirements
-----------

* Python 3.9 or higher
* Ansible 2.9 or higher
* Git

Installation Methods
------------------

From Source
~~~~~~~~~~

1. Clone the repository:

   .. code-block:: bash

      git clone https://github.com/your-org/rift.git
cd rift

2. Install the package:

   .. code-block:: bash

      pip install -e .

From RPM
~~~~~~~~

For Rocky Linux 9:

.. code-block:: bash

   sudo dnf install rift

Configuration
------------

After installation, you may need to configure Rift. The configuration file is located at:

.. code-block:: bash

   /etc/rift/config.yml

For more details about configuration options, see the :doc:`user-guide` section. 
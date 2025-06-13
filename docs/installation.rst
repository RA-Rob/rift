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

      git clone https://github.com/your-org/chasm.git
      cd chasm

2. Install the package:

   .. code-block:: bash

      pip install -e .

From RPM
~~~~~~~~

For Rocky Linux 9:

.. code-block:: bash

   sudo dnf install chasm

Configuration
------------

After installation, you may need to configure Chasm. The configuration file is located at:

.. code-block:: bash

   /etc/chasm/config.yml

For more details about configuration options, see the :doc:`user-guide` section. 
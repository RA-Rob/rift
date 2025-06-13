Development Guide
===============

Setting Up Development Environment
-------------------------------

1. Clone the repository:

   .. code-block:: bash

      git clone https://github.com/your-org/chasm.git
      cd chasm

2. Create a virtual environment:

   .. code-block:: bash

      python -m venv venv
      source venv/bin/activate  # On Windows: venv\Scripts\activate

3. Install development dependencies:

   .. code-block:: bash

      pip install -e ".[dev]"

Project Structure
--------------

::

   chasm/
   ├── chasm/              # Main package directory
   │   ├── __init__.py
   │   ├── cli.py         # Command-line interface
   │   ├── core.py        # Core functionality
   │   ├── inventory.py   # Inventory management
   │   ├── playbook.py    # Playbook management
   │   ├── role.py        # Role management
   │   ├── config.py      # Configuration handling
   │   └── utils.py       # Utility functions
   ├── tests/             # Test directory
   │   ├── __init__.py
   │   ├── test_cli.py
   │   ├── test_core.py
   │   └── ...
   ├── docs/              # Documentation
   ├── setup.py           # Package setup
   └── README.md          # Project README

Running Tests
-----------

Run the test suite:

.. code-block:: bash

   pytest

Run tests with coverage:

.. code-block:: bash

   pytest --cov=chasm

Code Style
---------

The project follows PEP 8 style guidelines. To check your code:

.. code-block:: bash

   flake8
   black .

Documentation
-----------

Build the documentation:

.. code-block:: bash

   cd docs
   make html

The documentation will be available in ``docs/_build/html/``.

Contributing
----------

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

Release Process
------------

1. Update version in ``VERSION`` file
2. Update changelog
3. Create a release tag
4. Build and publish package 
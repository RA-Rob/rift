Development Guide
===============

Setting Up Development Environment
-------------------------------

1. Clone the repository:

   .. code-block:: bash

      git clone https://github.com/your-org/rift.git
      cd rift

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

   rift/
   ├── rift/              # Main package directory
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

   pytest --cov=rift

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
3. Create a tag
4. Push changes and tag
5. GitHub Actions will build and release automatically

Testing
-------

Unit Tests
~~~~~~~~~

Write unit tests for all new functionality:

.. code-block:: python

   import unittest
   from rift.core import RiftCore

   class TestRiftCore(unittest.TestCase):
       def setUp(self):
           self.core = RiftCore()

       def test_initialization(self):
           self.assertIsNotNone(self.core)

Integration Tests
~~~~~~~~~~~~~~~

Integration tests verify the complete workflow:

.. code-block:: python

   def test_full_deployment():
       # Test complete deployment workflow
       pass

Code Quality
-----------

We use several tools to maintain code quality:

- **Black**: Code formatting
- **Flake8**: Style checking
- **pytest**: Testing framework
- **Coverage**: Code coverage analysis

Continuous Integration
--------------------

All code changes are tested using GitHub Actions:

- Run tests on multiple Python versions
- Check code style and formatting
- Build documentation
- Run security scans

Performance Testing
-----------------

For performance-critical code, use benchmarking:

.. code-block:: python

   import time
   
   def benchmark_function():
       start = time.time()
       # Your code here
       end = time.time()
       print(f"Function took {end - start:.2f} seconds")

Documentation Standards
---------------------

- Use reStructuredText for documentation
- Include docstrings for all public functions
- Add examples for complex functionality
- Keep documentation up to date with code changes 
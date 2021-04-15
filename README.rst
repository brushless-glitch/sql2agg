=======
SQL2AGG
=======

``SQL2AGG`` helps you quickly model a SQL query as a `MongoDB aggregation pipeline <https://docs.mongodb.com/manual/core/aggregation-pipeline/>`_.

*This tool is not intended for use in any production scenario.*

This project is designed for educational purposes. 

It aims to give curious developers ideas about how SQL statements might be expressed as MongoDB aggregation pipelines.

=======
Example
=======

``SQL2AGG`` helps you see what certain types of SQL queries would look like as MongoDB aggregation pipelines.

Let's say you have a SQL query in mind:

.. code-block:: none

   SELECT 
       qty, date, orderID 
   FROM 
      sales 
   WHERE
      qty > 100

What might an equivalent aggregation pipeline look like?

.. code-block:: javascript

	db.sales.aggregate([
	  {
		"$match": {
		  "$gt": {
			"qty": 100
		  }
		}
	  },
	  {
		"$project": {
		  "qty": 1,
		  "date": 1,
		  "orderID": 1
		}
	  }
	])

``SQL2AGG`` converts SQL statements into MongoDB aggregation pipelines automatically!

=========
Demo Site
=========

`Try it out now! <https://brushless-glitch.github.io/sql2agg/index.html>`_

======================
Supported SQL Features
======================

Example SQL Query 
-----------------

This query demonstrates a few of the SQL features and behaviors supported.

.. code-block:: none

   SELECT
       -- TOP keyword is duplicated with LIMIT
       TOP 100

       -- Verbatim fields
       field1, field2,

       -- name = field supported
       just_name = first_name,

       -- Arithmetic expressions
       i_square = SQRT(-1) ^ 2,
       total = (price - discount) * count + tax,

       -- Text concatenation
       full_name = first_name + ' ' + last_name
   FROM
       collection


Supported Mathematical/Logical Operators
----------------------------------------

- ``*``
- ``/``
- ``-``
- ``+``
- ``^``
- ``!``
- ``%``
- ``(``
- ``)``
- ``=``
- ``>=``
- ``<=``
- ``!=``
- ``<>``
- ``>``
- ``<``

Supported SQL Operators
-----------------------

- ``SELECT``
- ``FROM``
- ``WHERE``
- ``AND``
- ``OR``
- ``NOT``
- ``BETWEEN``
- ``IN``                    
- ``AS``
- ``LIKE``
- ``LEFT``                
- ``RIGHT``
- ``OUTER``
- ``JOIN``
- ``ON``
- ``ORDER``
- ``BY``
- ``ASCENDING``
- ``ASC``
- ``DESCENDING``
- ``DESC``
- ``TOP``
- ``LIMIT``
- ``SKIP``

=================
Known Limitations
=================

No Schema Validation
---------------------

- There is no schema validation. Fields are assumed to exist.

String Behavior
--------------

- Strings are not escaped. Example: ``'Johnson''s car'`` is not a valid string.
- ``LIKE`` operator **does not** sanitize incoming string for regex characters.

`JOIN` Restrictions
-------------------

- Only *one* ``LEFT OUTER JOIN`` is supported. The syntax must follow this example:

`[LEFT [OUTER]] JOIN <collection> ON <maincollection>.<field> = <collection>.<field>`

============
Installation
============

If you would like to run this locally, follow these steps:

1.) Clone the repository and ``cd`` to the project root.

.. code-block:: shell

   git clone git@github.com:brushless-glitch/sql2agg.git
   cd sql2agg 

2.) Install dependencies via `npm`.

.. code-block:: shell

   npm install -g jison
   npm install -g browserify

.. NOTE::

   The build tools may require ``xmlstarlet`` as a dependency. 

If ``make html`` produces the error message:

.. code-block:: none

   Must have xmlstarlet in order to build this project

Install ``xmlstarlet``. See the `xmlstarlet docs <http://xmlstar.sourceforge.net/doc/UG/xmlstarlet-ug.html>`_ for details.

.. code-block:: shell

   brew install xmlstarlet

3.) Build Locally.

Build the command line version:

.. code-block:: shell

   make build

Build the browser-based version:

.. code-block:: shell

   make html

Open the newly-created ``build/sql2agg.html`` in a browser.

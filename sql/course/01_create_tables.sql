-- Course version: load the four exercise CSVs from a Unity Catalog Volume into Delta tables.
-- Databricks for Data Analysts (LinkedIn Learning), chapter 1.

CREATE TABLE IF NOT EXISTS workspace.default.customers
AS SELECT *
FROM read_files(
  '/Volumes/workspace/default/baaraa_linkedin/customers.csv',
  format => 'csv',
  header => true,
  inferSchema => true
);

CREATE TABLE IF NOT EXISTS workspace.default.orders
AS SELECT *
FROM read_files(
  '/Volumes/workspace/default/baaraa_linkedin/orders.csv',
  format => 'csv',
  header => true,
  inferSchema => true
);

CREATE TABLE IF NOT EXISTS workspace.default.products
AS SELECT *
FROM read_files(
  '/Volumes/workspace/default/baaraa_linkedin/products.csv',
  format => 'csv',
  header => true,
  inferSchema => true
);

CREATE TABLE IF NOT EXISTS workspace.default.stores
AS SELECT *
FROM read_files(
  '/Volumes/workspace/default/baaraa_linkedin/stores.csv',
  format => 'csv',
  header => true,
  inferSchema => true
);

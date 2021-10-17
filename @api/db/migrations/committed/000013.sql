--! Previous: sha1:8c33f3bf739a07ce06e08cfae29bff6a614c07a2
--! Hash: sha1:4e11330076a07762a867f55986b75218c10512ee

--! split: 1-current.sql
-- Enter migration here
create table app_private.transferable_check_ins (
  company text,
  brand text,
  flavor text,
  category text,
  style text,
  rating text
)

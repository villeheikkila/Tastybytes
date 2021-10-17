--! Previous: sha1:6f4c0de43a74aba2bbd75b004cd1846249497cd4
--! Hash: sha1:2c73ae5db2c66bdbd5cd1ec0feb3a99d94e8c059

--! split: 1-current.sql
-- Enter migration here
DROP FUNCTION app_public.create_check_in(
  item_id integer,
  review text,
  rating app_public.rating,
  check_in_date date
);

--! Previous: sha1:8ffea8e2adcf8d1904684d47b99daa7741366bf9
--! Hash: sha1:c3836911fe72d552d8872a1950dba1d91ec4ac13

--! split: 1-current.sql
-- Enter migration here
DROP FUNCTION app_public.create_product(flavor text, type_id int, brand_id int, description text, manufacturer_id int);

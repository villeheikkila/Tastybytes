--! Previous: sha1:b40edc5a4493247344fb7ef6d12ec4d3b96b5658
--! Hash: sha1:61c96d21211bbc6785e512176a198d849a53be13

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.users DROP COLUMN name;

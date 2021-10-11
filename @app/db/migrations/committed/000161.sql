--! Previous: sha1:d8cb69c8feaf3b58c1a74d1833cd074ba46a2843
--! Hash: sha1:88efbd99a4406feead3dd887546a264db773ad35

--! split: 1-current.sql
-- Enter migration here
alter table app_public.brands drop constraint brands_name_check;
alter table app_public.brands alter column name type short_text;

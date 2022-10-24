--! Previous: sha1:609a0a12d763aa3377f1141a5631780ce302ffda
--! Hash: sha1:c333c528b87c6debeabe3239ce63b06dbcfa505b

--! split: 1-current.sql
-- Enter migration here
alter table app_public.user_settings add column is_public boolean;

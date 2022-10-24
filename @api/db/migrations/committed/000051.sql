--! Previous: sha1:96e0cf99aeb85779a160a36d710d9a03754378b3
--! Hash: sha1:f8e3cb8062745e8acf6c75adeeb55fe982028b8d

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.user_settings
  rename column public_check_ins to is_public_check_ins;

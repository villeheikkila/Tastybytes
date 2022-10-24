--! Previous: sha1:031e1d23fe547aa8ea8b47c245ac44a2de4d1fdc
--! Hash: sha1:ed704d108e07d82416146fb579591c71bada0231

--! split: 1-current.sql
-- Enter migration here
alter table app_public.user_settings alter column is_public set default true;

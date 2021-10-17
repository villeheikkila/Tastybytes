--! Previous: sha1:3cefbd002282a6f587ac174b8ce083f46817b175
--! Hash: sha1:2230027d9fa9b092db516003f6ddb68ea38dbfef

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.brands ADD COLUMN created_by uuid references app_public.users(id) on delete set null;

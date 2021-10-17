--! Previous: sha1:331ebb9e56bdb4a369c7647bf6962ee1aeedc1b7
--! Hash: sha1:b3498e908eda4e9e24ec11bf17a3219e0483ebad

--! split: 1-current.sql
-- Enter migration here
alter table app_public.check_in_comments add column created_at timestamptz not null default now();

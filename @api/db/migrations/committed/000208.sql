--! Previous: sha1:7bde59025050aeee2911b20451f245845bd4f963
--! Hash: sha1:546e98977050fdf62a028a4bef8053532694f0b6

--! split: 1-current.sql
-- Enter migration here

create function app_public.current_user_is_admin() returns boolean
  language sql stable security definer
  set search_path to 'pg_catalog', 'public', 'pg_temp'
as
$$
select is_admin from app_public.current_user();
$$

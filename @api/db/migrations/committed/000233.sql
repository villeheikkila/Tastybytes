--! Previous: sha1:8123fbd861546bd2275d04820e6e1d34cad0d783
--! Hash: sha1:13ad3705363c1c6a60adf0a2316051247bd2af9b

--! split: 1-current.sql
create or replace function app_private.tg__created() returns trigger
    language plpgsql
    set search_path to 'pg_cata'
    as $$
begin
  new.created_by = app_public.current_user_id();
  new.is_verified = app_public.current_user_is_privileged ();
  return new;
end;
$$;

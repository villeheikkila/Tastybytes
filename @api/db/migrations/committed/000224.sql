--! Previous: sha1:6adf85bb5798700cebbacc99be861bfd16c23de9
--! Hash: sha1:20278bc81b9453f9e70f771a786bd99cf060b2aa

--! split: 1-current.sql
-- Enter migration here
create function app_private.tg__created() returns trigger as $$
begin
  NEW.created_at = NOW();
  NEW.created_by = app_public.current_user_id();
  NEW.is_verified = app_public.current_user_is_privileged ();
  return NEW;
end;
$$ language plpgsql volatile set search_path to pg_cata

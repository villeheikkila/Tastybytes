--! Previous: sha1:20278bc81b9453f9e70f771a786bd99cf060b2aa
--! Hash: sha1:4cd54a7c27be2ee7af4fc09dca66b1b9a9b719eb

--! split: 1-current.sql
-- Enter migration here
GRANT INSERT (name) ON TABLE app_public.tags TO tasted_visitor;

CREATE POLICY logged_in_insert ON app_public.tags
  FOR INSERT
    WITH CHECK ((app_public.current_user_id () IS NOT NULL));

CREATE TRIGGER _100_timestamps
  BEFORE INSERT ON app_public.tags
  FOR EACH ROW
  EXECUTE FUNCTION app_private.tg__created ();

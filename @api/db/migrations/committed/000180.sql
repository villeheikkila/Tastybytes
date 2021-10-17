--! Previous: sha1:91c7fa185d6df381a1dbf506db1272637a5ed5d2
--! Hash: sha1:d0d1f9eeb425172811bf4cead2b5284c7cb4ecc2

--! split: 1-current.sql
-- Enter migration here
CREATE POLICY create_check_in ON app_public.check_ins
  FOR INSERT
    WITH CHECK (app_public.current_user_id () IS NOT NULL);

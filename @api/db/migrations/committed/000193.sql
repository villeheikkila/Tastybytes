--! Previous: sha1:a21a3efaf344efd8102e29d9e749e613db9c5cf7
--! Hash: sha1:88727b453745568033c71db3417a8c41367b517b

--! split: 1-current.sql
-- Enter migration here
CREATE POLICY select_public ON app_public.check_ins FOR SELECT USING ((SELECT is_public from app_public.check_ins));

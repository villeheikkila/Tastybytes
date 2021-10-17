--! Previous: sha1:94dea9d15a742c57214f4404fe4d309227e11073
--! Hash: sha1:91c7fa185d6df381a1dbf506db1272637a5ed5d2

--! split: 1-current.sql
-- Enter migration here
CREATE POLICY update_own ON app_public.check_ins FOR UPDATE USING ((author_id = app_public.current_user_id()));

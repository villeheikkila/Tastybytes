--! Previous: sha1:800ebc7885146d6997ba58c3e16b49ff1d66d4e7
--! Hash: sha1:d3779a8bbbdd79a33e8532ce8caa00c349d62a73

--! split: 1-current.sql
-- Enter migration here
CREATE POLICY select_all ON app_public.friends FOR SELECT USING (true);

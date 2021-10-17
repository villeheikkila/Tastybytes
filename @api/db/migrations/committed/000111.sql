--! Previous: sha1:d65d233bf30683342caf4176113ed972bbfeed8f
--! Hash: sha1:6a52fbef137daa4705a06aa4dbe234d1317800a6

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX check_ins_created_at_idx ON app_public.check_ins USING btree (created_at);

--! Previous: sha1:1661903e333132c45ab205b7108ea7805a643c7f
--! Hash: sha1:04196a6c8d480bf54c238e1c882c3b472a162850

--! split: 1-current.sql
-- Enter migration here
alter table app_public.friends add column id serial;

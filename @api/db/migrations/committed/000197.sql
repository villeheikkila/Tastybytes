--! Previous: sha1:654e8e868d16c250d9aa0786eeddc7318e0d6d91
--! Hash: sha1:de3615da0c139354f9f0de39d833957dc0ddd50d

--! split: 1-current.sql
-- Enter migration here

create policy select_public on app_public.check_ins for select using ((is_public = true));

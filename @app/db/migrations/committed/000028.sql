--! Previous: sha1:ae28a87e40c87be7494b1bc18a6869b4a86310da
--! Hash: sha1:ac5a0da4ce56b71f6ad81b96e767701f48e33082

--! split: 1-current.sql
-- Enter migration here
alter table app_public.items
alter column brand_id
set not null;

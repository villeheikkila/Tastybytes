--! Previous: sha1:e9b2874b6f11739f4c2cb4bd27bc7642594890ee
--! Hash: sha1:b734ab246bcaba73aadaa80a91d51734cabe36e0

--! split: 1-current.sql
-- Enter migration here
create domain app_public.rating as integer check (value >= 0 and value <= 10);

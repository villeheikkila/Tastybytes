--! Previous: sha1:b734ab246bcaba73aadaa80a91d51734cabe36e0
--! Hash: sha1:6954279d4c92f3054390dd40f1cf19789070343d

--! split: 1-current.sql
-- Enter migration here
create domain app_public.name as text check (
  (length(value) >= 2)
  AND (length(value) <= 56)
);

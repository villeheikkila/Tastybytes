--! Previous: sha1:9f4052e1922aa6ae33d071e384eb29cd9ea70ba9
--! Hash: sha1:4044f055fbae6acfaf11146b3f909e0b728e3a60

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id)';

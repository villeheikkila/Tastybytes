--! Previous: sha1:4044f055fbae6acfaf11146b3f909e0b728e3a60
--! Hash: sha1:44538ee0c6bb70831d6adea0971092d93a001f0a

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id) \n @foreignKey (author_id) references app_public.users(id)';

--! Previous: sha1:44538ee0c6bb70831d6adea0971092d93a001f0a
--! Hash: sha1:c5cc2b018d08f41a8835aa165cf28aeb23e3929c

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id)\n@foreignKey (author_id) references app_public.users(id)';

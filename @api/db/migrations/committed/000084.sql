--! Previous: sha1:40ae9745a968eb973dcc013ff3421e5b799b496b
--! Hash: sha1:019d025132ae39baf64eb181297953cd77cada50

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id) @foreignKey (author_id) references app_public.users(id)';

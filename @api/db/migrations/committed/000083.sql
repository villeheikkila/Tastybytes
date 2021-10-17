--! Previous: sha1:3a75e58408a3d60d4ab5b7e397fba3bf9e3a5942
--! Hash: sha1:40ae9745a968eb973dcc013ff3421e5b799b496b

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id) \n @foreignKey (author_id) references app_public.users(id)';

--! Previous: sha1:d5f2187622d812dacc14be439e320d7f68c33141
--! Hash: sha1:3a75e58408a3d60d4ab5b7e397fba3bf9e3a5942

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id)|@foreignKey (author_id) references app_public.users(id)';

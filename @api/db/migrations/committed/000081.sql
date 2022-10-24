--! Previous: sha1:f0beaec0e6509140bfb2421ac4c5d4a13b7c4714
--! Hash: sha1:d5f2187622d812dacc14be439e320d7f68c33141

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id)|@foreignKey (author_id) references app_public.authors(id)';

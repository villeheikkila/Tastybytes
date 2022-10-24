--! Previous: sha1:019d025132ae39baf64eb181297953cd77cada50
--! Hash: sha1:efe4a3b553ef794e2e1664e3066a3b388c74befc

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id)\@foreignKey (author_id) references app_public.users(id)';

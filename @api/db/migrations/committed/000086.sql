--! Previous: sha1:efe4a3b553ef794e2e1664e3066a3b388c74befc
--! Hash: sha1:9f4052e1922aa6ae33d071e384eb29cd9ea70ba9

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id) \n @foreignKey (author_id) references app_public.users(id)';

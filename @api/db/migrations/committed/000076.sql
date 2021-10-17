--! Previous: sha1:4d87579d8e4be332c812b35e30a5bc7eba42cbb8
--! Hash: sha1:db027e0c767ece9725b77c2fc58dfa6af642ebb0

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.item_id(id)|@foreignKey (author_id) references app_public.author_id(id)';

--! Previous: sha1:55acd3388c1c1c091bb14692ed872a46ebed2920
--! Hash: sha1:9b11d881f7c35b7921155a684089d0c2758ec9ca

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.activity_feed is
  E'@foreignKey (item_id) references app_public.items(id)\n@foreignKey (author_id) references app_public.users(id)';

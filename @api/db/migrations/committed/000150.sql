--! Previous: sha1:631b1a7b15e78595b87d4e2efbfeed6a3667ae01
--! Hash: sha1:cb069fbb6c1efe2fdeb8c81aa909afecd2c0835a

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.items(id) @foreignKey (author_id) references app_public.users(id)';

comment on view app_public.activity_feed is
  E'@foreignKey (item_id) references app_public.items(id)\n@foreignKey (author_id) references app_public.users(id)';

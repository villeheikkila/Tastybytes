--! Previous: sha1:5043d7012d696c3d4322eec2da5ab0a7a6fae516
--! Hash: sha1:d4ff2ed415d303f054d19db4fbb46378adbc9d0b

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.item_id(id)';

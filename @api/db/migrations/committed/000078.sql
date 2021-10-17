--! Previous: sha1:362521183de589ae3d2d93107428ac2b42103523
--! Hash: sha1:5043d7012d696c3d4322eec2da5ab0a7a6fae516

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (item_id) references app_public.item_id(id)|@foreignKey (author_id) references app_public.author_id(id)';

--! Previous: sha1:0139af9f6c05f6d9609e1fd10463a0c0064a2f73
--! Hash: sha1:efdae1ee1c523abceba2d0d3dd1fea4c835af8dc

--! split: 1-current.sql
-- Enter migration here
alter table app_public.item_edit_suggestions add column type_id int references app_public.types(id) not null;

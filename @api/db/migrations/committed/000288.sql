--! Previous: sha1:5221189d6a7f7d78d5dcd4b726bd73d49da4faa6
--! Hash: sha1:5939d831ccccb409a6cf8bd70896f8d564e897c3

--! split: 1-current.sql
create or replace function app_public.search_items(search text)
  returns setof app_public.items as $$
    select i.*
    from app_public.items i
    where
      flavor ilike ('%' || search || '%');
  $$ language sql stable;

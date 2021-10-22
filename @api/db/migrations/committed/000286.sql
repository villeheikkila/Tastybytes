--! Previous: sha1:303d34fb8b09e51c6eab974566f8636d836fed17
--! Hash: sha1:f47a10a474138ce48b222b2be5da3cca31fcff5f

--! split: 1-current.sql
create or replace function app_public.search_items(search text)
  returns setof app_public.items as $$
    select *
    from app_public.items i
    where
      flavor ilike ('%' || search || '%');
  $$ language sql stable;

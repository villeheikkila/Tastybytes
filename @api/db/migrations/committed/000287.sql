--! Previous: sha1:f47a10a474138ce48b222b2be5da3cca31fcff5f
--! Hash: sha1:5221189d6a7f7d78d5dcd4b726bd73d49da4faa6

--! split: 1-current.sql
create or replace function app_public.search_items(search text)
  returns setof app_public.items as $$
    select i.*
    from app_public.items i
    join app_public.brands b on i.brand_id = b.id
    join app_public.companies c on c.id = b.id
    where
      flavor ilike ('%' || search || '%') or
      c.name ilike ('%' || search || '%') or
      b.name ilike ('%' || search || '%');
  $$ language sql stable;

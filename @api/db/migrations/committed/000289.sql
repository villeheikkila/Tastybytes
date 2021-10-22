--! Previous: sha1:5939d831ccccb409a6cf8bd70896f8d564e897c3
--! Hash: sha1:60c9d1490f7c3d28c29095afc8959c3d227a42fe

--! split: 1-current.sql
create or replace function app_public.search_items(search text)
  returns setof app_public.items as $$
    select i.*
    from app_public.items i
    join app_public.brands b on i.brand_id = b.id
    join app_public.companies c on c.id = b.id
    where
      flavor ilike ('%' || search || '%');
  $$ language sql stable;

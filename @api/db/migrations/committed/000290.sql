--! Previous: sha1:60c9d1490f7c3d28c29095afc8959c3d227a42fe
--! Hash: sha1:abe3258478cf88c378593e50258ae33be249ff09

--! split: 1-current.sql
create or replace function app_public.search_items(search text)
  returns setof app_public.items as $$
    select i.*
    from app_public.items i
    join app_public.brands b on i.brand_id = b.id
    join app_public.companies c on c.id = b.id
    where
      concat(c.name, ' ', b.name, ' ', i.flavor) ilike ('%' || search || '%');
  $$ language sql stable;

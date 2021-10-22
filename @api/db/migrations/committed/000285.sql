--! Previous: sha1:8f316d6e6f78ebd88633d02aeadd5216645dddd2
--! Hash: sha1:303d34fb8b09e51c6eab974566f8636d836fed17

--! split: 1-current.sql
create function app_public.search_items(search text)
  returns setof app_public.items as $$
    select i.*
    from app_public.items i
    join app_public.brands b on i.brand_id = b.id
    join app_public.companies c on c.id = b.id
    where
      i.flavor ilike ('%' || search || '%') or
      c.name ilike ('%' || search || '%') or
      b.name ilike ('%' || search || '%')
  $$ language sql stable;

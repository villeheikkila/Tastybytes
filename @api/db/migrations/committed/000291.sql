--! Previous: sha1:abe3258478cf88c378593e50258ae33be249ff09
--! Hash: sha1:1fa88b89a70dccb6ec604d0cf1da2caa41af555f

--! split: 1-current.sql
create or replace function app_public.search_items(search text)
  returns setof app_public.items as
$$
select item.*
from (select i.id                pid,
             to_tsvector(i.flavor) ||
             to_tsvector(b.name) ||
             to_tsvector(c.name) as document
      from app_public.items i
             join app_public.brands b on i.brand_id = b.id
             join app_public.companies c on c.id = b.id
      group by i.id, b.id, c.id) p_search
left join app_public.items item on item.id = pid
where p_search.document @@ to_tsquery(search);
$$ language sql stable;

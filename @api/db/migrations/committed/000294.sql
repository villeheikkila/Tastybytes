--! Previous: sha1:31a5ffc9bf8169cfe47c2b4ea41ab66f17b99acd
--! Hash: sha1:0176ad54b079d3fc60b9ab8834c43615f7b4e123

--! split: 1-current.sql
create or replace function app_public.search_items(search text)
  returns setof app_public.items as
$$
with search_agg as (
  select i.id                   ,
         to_tsvector(i.flavor) ||
         to_tsvector(b.name) ||
         to_tsvector(c.name) as document
  from app_public.items i
         join app_public.brands b on i.brand_id = b.id
         join app_public.companies c on c.id = b.company_id
  ) select i.*  from search_agg s left join app_public.items i on i.id = s.id where document @@ plainto_tsquery(search);
$$ language sql stable;

--! Previous: sha1:d43e6c31368c77a6e1f89ed1511d65db6d7412b9
--! Hash: sha1:e39365ec90892a9991c2a877fedbeddb4f412b8c

-- Enter migration here
create or replace function tasted_public.search_items(search text)
  returns setof tasted_public.products as
$$
with search_agg as (
  select i.id                   ,
         to_tsvector(i.name) ||
         to_tsvector(b.name) ||
         to_tsvector(c.name) as document
  from tasted_public.products i
         join tasted_public.brands b on i.brand_id = b.id
         join tasted_public.companies c on c.id = b.company_id
  ) select i.*  from search_agg s left join tasted_public.products i on i.id = s.id where document @@ plainto_tsquery(search);
$$ language sql stable;

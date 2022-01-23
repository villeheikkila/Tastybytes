--! Previous: sha1:e2bb27b55b4e92d9c1b62a5f2d67a835c5d5b5ee
--! Hash: sha1:d9a575b20f995f56aff507f1caf232bb0cd7fd74

-- Enter migration here
drop function tasted_public.search_items(text);

create or replace function tasted_public.search_products(search text)
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

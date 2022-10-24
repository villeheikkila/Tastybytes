--! Previous: sha1:1fa88b89a70dccb6ec604d0cf1da2caa41af555f
--! Hash: sha1:a246fa3d248620bdc1713fbeebebe53cced75371

--! split: 1-current.sql
with search_agg as (
  select i.id                   ,
         to_tsvector(i.flavor) ||
         to_tsvector(b.name) ||
         to_tsvector(c.name) as document
  from app_public.items i
         join app_public.brands b on i.brand_id = b.id
         join app_public.companies c on c.id = b.company_id
  ) select i.*  from search_agg s left join app_public.items i on i.id = s.id where document @@ to_tsquery('coca');

--! Previous: sha1:553d03873a2aa7156901cadf6bd04bc7d5806ee3
--! Hash: sha1:bdcdd486125653214e19f50b0b10d57797bc7db2

-- Enter migration here
create or replace procedure tasted_private.migrate_seed()
  language sql
as
$$
insert into tasted_public.companies (name)
select distinct company as name
from tasted_private.transferable_check_ins
on conflict do nothing;
insert into tasted_public.categories (name)
select distinct category as name
from tasted_private.transferable_check_ins
on conflict do nothing;
with types as (
  select distinct category,
                  style as name
  from tasted_private.transferable_check_ins
)
insert
into tasted_public.types (name, category)
select name,
       category
from types
on conflict do nothing;
with brands as (
  select distinct brand,
                  company
  from tasted_private.transferable_check_ins
)
insert
into tasted_public.brands (name, company_id)
select b.brand as name,
       c.id    as company_id
from brands b
       left join tasted_public.companies c on b.company = c.name
on conflict do nothing;
with products as (
  select b.id as brand_id,
         p.flavor as name,
         p.category as category,
         c.id as manufacturer_id,
         t.id as type_id
  from tasted_private.transferable_check_ins p
         left join tasted_public.companies c on p.company = c.name
         left join tasted_public.types t on p.style = t.name
    and p.category = t.category
         left join tasted_public.brands b on p.brand = b.name
    and b.company_id = c.id
)
insert
into tasted_public.products (name, brand_id, category, manufacturer_id, type_id)
select name,
       brand_id,
       category,
       manufacturer_id,
       type_id
from products
on conflict do nothing;
with check_ins as (
  select case
           when length(p.rating) > 0 then (
             replace(p.rating, ',', '.')::decimal * 2
             )::integer
           else null
           end as rating,
         i.id  as product_id
  from tasted_private.transferable_check_ins p
         left join tasted_public.companies c on p.company = c.name
         left join tasted_public.brands b on b.company_id = c.id
    and b.name = p.brand
         left join tasted_public.categories k on k.name = p.category
         left join tasted_public.types t on t.category = k.name
    and p.style = t.name
         left join tasted_public.products i on i.manufacturer_id = c.id
    and b.id = i.brand_id
    and i.category = p.category
    and i.name = p.flavor
    and i.type_id = t.id
)
insert
into tasted_public.check_ins (rating, product_id, author_id)
select rating,
       i.product_id as product_id,
       (
         select id
         from tasted_public.users
         where username = 'villeheikkila'
       )         as author_id
from check_ins i
$$;

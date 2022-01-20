--! Previous: sha1:fbcd013860d02a756c8d446cb13e26d075c0529b
--! Hash: sha1:5fb6ad7ddab02b5b5a3966d8cdd791cfac9704c1

-- Enter migration here
drop table tasted_public.check_ins;

create table tasted_public.check_ins (
  id serial primary key,
  rating integer,
  review text,
  product_id integer not null references tasted_public.products(id) on delete cascade,
  author_id uuid not null references tasted_public.users(id) on delete cascade,
  check_in_date date,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  CONSTRAINT check_ins_review_check CHECK (
    (length(review) >= 1)
    AND (length(review) <= 1024)
  ),
  CONSTRAINT check_ins_rating CHECK (
    rating >= 0
    AND rating <= 10
  )
);

create table tasted_private.transferable_check_ins (
  company text,
  brand text,
  flavor text,
  category text,
  style text,
  rating text
);

alter table tasted_public.products add manufacturer_id integer references tasted_public.companies(id) on delete cascade;


create procedure tasted_private.migrate_seed()
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
into tasted_public.products (name, brand_id, manufacturer_id, type_id)
select name,
       brand_id,
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

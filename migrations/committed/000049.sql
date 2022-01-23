--! Previous: sha1:e39365ec90892a9991c2a877fedbeddb4f412b8c
--! Hash: sha1:e2bb27b55b4e92d9c1b62a5f2d67a835c5d5b5ee

-- Enter migration here
create or replace function tasted_public.companies_total_check_ins(c tasted_public.companies)
  returns int
  language sql
  stable
as
$$
select count(1) from tasted_public.check_ins ci
left join tasted_public.products i on ci.product_id = i.id
left join tasted_public.brands b on i.brand_id = b.id
left join tasted_public.companies co on b.company_id = co.id
where co.id = c.id
$$;

create or replace function tasted_public.companies_check_ins_past_month(c tasted_public.companies)
  returns int
  language sql
  stable
as
$$
select count(1) from tasted_public.check_ins ci
left join tasted_public.products i on ci.product_id = i.id
left join tasted_public.brands b on i.brand_id = b.id
left join tasted_public.companies co on b.company_id = co.id
where co.id = c.id and ci.created_at >= current_date - interval '1 month';
$$;

create or replace function tasted_public.companies_total_items(c tasted_public.companies)
  returns int
  language sql
  stable
as
$$
select count(1) from tasted_public.products i
left join tasted_public.brands b on i.brand_id = b.id
where c.id = b.company_id;
$$;


create or replace function tasted_public.companies_average_rating(c tasted_public.companies)
  returns int
  language sql
  stable
as
$$
with company_items_avg_by_user as (select ci.product_id, ci.author_id, avg(ci.rating) average from tasted_public.check_ins ci
left join tasted_public.products i on ci.product_id = i.id
left join tasted_public.brands b on i.brand_id = b.id
left join tasted_public.companies co on b.company_id = co.id where co.id = c.id group by (ci.product_id, ci.author_id)) select avg(average) as average from company_items_avg_by_user;
$$;

create or replace function tasted_public.products_total_check_ins(i tasted_public.products)
  returns int
  language sql
  stable
as
$$
select count(1)
from tasted_public.check_ins
where product_id = i.id
$$;

create or replace function tasted_public.products_check_ins_past_month(i tasted_public.products)
  returns int
  language sql
  stable
as
$$
select count(1)
from tasted_public.check_ins
where product_id = i.id and created_at >= current_date - interval '1 month';
$$;

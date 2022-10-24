--! Previous: sha1:e37955252cffd605186742cbc19d8799fefef472
--! Hash: sha1:885bfbd23abed5a2a9a0e32dcdbc50a4773d806f

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.companies_average_rating(c app_public.companies)
  returns int
  language sql
  stable
as
$$
with company_items_avg_by_user as (select ci.item_id, ci.author_id, avg(ci.rating) average from app_public.check_ins ci
left join app_public.items i on ci.item_id = i.id
left join app_public.brands b on i.brand_id = b.id
left join app_public.companies co on b.company_id = co.id where co.id = c.id group by (ci.item_id, ci.author_id)) select avg(average) as average from company_items_avg_by_user;
$$;

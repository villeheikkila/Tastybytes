--! Previous: sha1:51de7c03080978c1272643ee99acf29671c29882
--! Hash: sha1:e37955252cffd605186742cbc19d8799fefef472

--! split: 1-current.sql
create or replace function app_public.companies_total_check_ins(c app_public.companies)
  returns int
  language sql
  stable
as
$$
select count(1) from app_public.check_ins ci
left join app_public.items i on ci.item_id = i.id
left join app_public.brands b on i.brand_id = b.id
left join app_public.companies co on b.company_id = co.id
where co.id = c.id
$$;

create or replace function app_public.companies_current_user_check_ins(c app_public.companies)
  returns int
  language sql
  stable
as
$$
select count(1) from app_public.check_ins ci
left join app_public.items i on ci.item_id = i.id
left join app_public.brands b on i.brand_id = b.id
left join app_public.companies co on b.company_id = co.id
where co.id = c.id and author_id = app_public.current_user_id()
$$;

create or replace function app_public.companies_check_ins_past_month(c app_public.companies)
  returns int
  language sql
  stable
as
$$
select count(1) from app_public.check_ins ci
left join app_public.items i on ci.item_id = i.id
left join app_public.brands b on i.brand_id = b.id
left join app_public.companies co on b.company_id = co.id
where co.id = c.id and ci.created_at >= current_date - interval '1 month';
$$;

create or replace function app_public.companies_total_items(c app_public.companies)
  returns int
  language sql
  stable
as
$$
select count(1) from app_public.items i
left join app_public.brands b on i.brand_id = b.id
where c.id = b.company_id;
$$;

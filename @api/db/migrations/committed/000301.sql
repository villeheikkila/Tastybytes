--! Previous: sha1:bf2dadaa10f1ae21482ac18aae4a08295aa0c95f
--! Hash: sha1:f892be9610cebef202705a520d5e96173da2b3a4

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.items_average_rating(i app_public.items)
  returns numeric
  language sql
  stable
as
$$
select avg(c.rating)::numeric(10,2) from app_public.check_ins c where c.item_id = i.id;
$$;

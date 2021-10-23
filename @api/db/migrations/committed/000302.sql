--! Previous: sha1:f892be9610cebef202705a520d5e96173da2b3a4
--! Hash: sha1:aa51406d4744d24cffd301aed444e7c0236e8bad

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.items_unique_check_ins(i app_public.items)
  returns int
  language sql
  stable
as
$$
select count(distinct c.author_id) from app_public.check_ins c where c.item_id = i.id;
$$;

--! Previous: sha1:15c313d3a5f69acc27a4c8f557b71e10cfa6635d
--! Hash: sha1:8af2dbd5561a693313f6ea3899905f98050b7d62

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.items_is_tasted(i app_public.items)
  returns boolean
  language sql
  stable
as
$$
select exists(select 1
              from app_public.check_ins c
              where c.author_id = app_public.current_user_id()
                and c.item_id = i.id)::boolean;
$$;

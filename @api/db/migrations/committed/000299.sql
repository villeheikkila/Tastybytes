--! Previous: sha1:8af2dbd5561a693313f6ea3899905f98050b7d62
--! Hash: sha1:d05d87ff15d15d7f804ea3525b1db47aa96802e9

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
                and c.item_id = i.id);
$$;

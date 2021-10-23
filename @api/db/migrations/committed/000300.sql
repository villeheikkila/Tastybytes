--! Previous: sha1:d05d87ff15d15d7f804ea3525b1db47aa96802e9
--! Hash: sha1:bf2dadaa10f1ae21482ac18aae4a08295aa0c95f

--! split: 1-current.sql
-- Enter migration here
drop function app_public.items_is_tasted(i app_public.items);
drop function app_public.items_is_tasted(u app_public.users);

create or replace function app_public.items_is_tasted(i app_public.items)
  returns boolean
  language sql
  stable
as
$$
select exists(select 1
              from app_public.check_ins c
              where c.author_id = app_public.current_user_id()
                and c.item_id = i.id)::boolean
$$;

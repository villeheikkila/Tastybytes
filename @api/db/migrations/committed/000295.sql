--! Previous: sha1:0176ad54b079d3fc60b9ab8834c43615f7b4e123
--! Hash: sha1:c99dc6376a19a936c098b0c5ea9a812a33056b7b

--! split: 1-current.sql
-- Enter migration here
create function app_public.items_is_tasted(u app_public.users)
  returns boolean
  language sql
  stable
as
$$
select exists(select 1
              from app_public.items i
                     join app_public.check_ins c on c.item_id = i.id
              where c.author_id = app_public.current_user_id())::boolean
$$;

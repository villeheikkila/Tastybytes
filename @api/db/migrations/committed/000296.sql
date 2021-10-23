--! Previous: sha1:c99dc6376a19a936c098b0c5ea9a812a33056b7b
--! Hash: sha1:74d117ddd700fcaff60d0650ecc1c06a3ba2c84e

--! split: 1-current.sql
-- Enter migration here
create function app_public.items_is_tasted(i app_public.items)
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

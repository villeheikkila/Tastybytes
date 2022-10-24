--! Previous: sha1:90a61b83aff5827a584a78bf42534e68db0c6a4c
--! Hash: sha1:f063c0307e99c13d0617401ffc37c4b649a3f62e

--! split: 1-current.sql
-- Enter migration here
drop function app_public.users_friend_status(u app_public.users);

create function app_public.users_friend_status(u app_public.users)
  returns record
  language sql
  stable
as
$$
select status, case when (user_id_1 = app_public.current_user_id()) then true else false end as is_sender
from app_public.friends
where (user_id_1 = u.id and user_id_2 = app_public.current_user_id())
   or (user_id_2 = u.id and user_id_1 = app_public.current_user_id())
$$;

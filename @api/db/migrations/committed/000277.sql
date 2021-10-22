--! Previous: sha1:2df8f1c4aee036e4097e6b38ecdf62bc9e3c3375
--! Hash: sha1:90a61b83aff5827a584a78bf42534e68db0c6a4c

--! split: 1-current.sql
-- Enter migration here
drop function app_public.users_friend_status(u app_public.users);

create function app_public.users_friend_status(u app_public.users)
  returns TABLE(status app_public.friend_status, is_sender boolean)
  language sql
  stable
as
$$
select status, case when (user_id_1 = app_public.current_user_id()) then true else false end as is_sender
from app_public.friends
where (user_id_1 = u.id and user_id_2 = app_public.current_user_id())
   or (user_id_2 = u.id and user_id_1 = app_public.current_user_id())
$$;

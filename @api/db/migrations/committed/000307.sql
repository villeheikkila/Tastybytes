--! Previous: sha1:c6faa8e4785163215916c975be44828071c93a2f
--! Hash: sha1:01894dffd7f6a754fbbfc41cf68d11509b81e30f

--! split: 1-current.sql
create function app_public.users_total_friends(u app_public.users)
  returns int
  language sql
  stable
as
$$
select count(1)
from app_public.friends
where (user_id_1 = u.id and user_id_2 = app_public.current_user_id())
   or (user_id_2 = u.id and user_id_1 = app_public.current_user_id())
$$;

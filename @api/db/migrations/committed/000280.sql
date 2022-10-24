--! Previous: sha1:d4dbe9a6ce4acc7fe2ca8a476dafd012d761b44f
--! Hash: sha1:c74494aa5cadafb887de99310ede54fecfec11b5

--! split: 1-current.sql
drop function app_public.users_friends(u app_public.users);

create or replace function app_public.users_friends(u app_public.users)
  returns table
          (
            id         uuid,
            first_name text,
            last_name  text,
            username   text,
            avatar_url text,
            status     app_public.friend_status,
            is_sender  boolean
          )
  language sql
  stable
as
$$
with user_friends as (select urs.id, urs.first_name, urs.last_name, urs.username, urs.avatar_url
                      from app_public.friends f
                             left join app_public.users urs
                                       on (f.user_id_2 = urs.id and f.user_id_1 = u.id) or
                                          (f.user_id_1 = urs.id and f.user_id_2 = u.id)
                      where f.user_id_1 = u.id
                         or f.user_id_2 = u.id)
select uf.*,
       f.status                                                                         status,
       case when (user_id_1 = app_public.current_user_id()) then true else false end as is_sender
from user_friends uf
       left join app_public.friends f
                 on (f.user_id_1 = uf.id and f.user_id_2 = app_public.current_user_id()) or
                    (f.user_id_2 = uf.id and f.user_id_1 = app_public.current_user_id());
$$;

--! Previous: sha1:5b4d6faf7c6333515cce1cf582ace83d673fc0cf
--! Hash: sha1:2df8f1c4aee036e4097e6b38ecdf62bc9e3c3375

--! split: 1-current.sql
-- Enter migration here
drop function app_public.users_friends(u app_public.users);

create or replace function app_public.users_friends(u app_public.users)
  returns table
          (
            id                  uuid,
            first_name          text,
            last_name           text,
            username            text,
            avatar_url          text,
            friend_status app_public.friend_status
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
select uf.*, f.status friend_status
from user_friends uf
       left join app_public.friends f
                 on (f.user_id_1 = uf.id and f.user_id_2 = app_public.current_user_id()) or
                    (f.user_id_2 = uf.id and f.user_id_1 = app_public.current_user_id());
$$;

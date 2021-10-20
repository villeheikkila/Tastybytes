--! Previous: sha1:d3779a8bbbdd79a33e8532ce8caa00c349d62a73
--! Hash: sha1:e020a5d2715bac503c2df87cc6f72a3bb9e075bd

--! split: 1-current.sql
drop function app_public.users_friends(u app_public.users);

create or replace function app_public.users_friends(u app_public.users)
  returns table
          (
            id                  uuid,
            first_name          text,
            last_name           text,
            username            text,
            avatar_url          text,
            current_user_status app_public.friend_status
          )
  language sql
  stable
as
$$
with user_friends as (select urs.id, urs.first_name, urs.last_name, urs.username, urs.avatar_url
                      from app_public.friends f
                             left join app_public.users urs
                                       on f.user_id_2 = urs.id or
                                          f.user_id_1 = urs.id
                      where f.user_id_1 = u.id
                         or f.user_id_2 = u.id)
select uf.*, f.status current_user_status
from user_friends uf
       left join app_public.friends f
                 on (f.user_id_1 = uf.id and f.user_id_2 = app_public.current_user_id()) or
                    (f.user_id_2 = uf.id and f.user_id_1 = app_public.current_user_id());
$$;

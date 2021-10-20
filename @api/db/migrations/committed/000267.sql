--! Previous: sha1:360c2ead31f6864aad43f80de38281a5be48ed87
--! Hash: sha1:8c8a4d75004a3d80ba6a9cebdac6abc31aa05ed8

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
            avatar_url          text
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
select uf.*
from user_friends uf
$$;

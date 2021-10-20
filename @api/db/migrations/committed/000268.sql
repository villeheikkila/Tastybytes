--! Previous: sha1:8c8a4d75004a3d80ba6a9cebdac6abc31aa05ed8
--! Hash: sha1:53cc709ef653287eebf6181a0cd5c3fb87e15399

--! split: 1-current.sql
-- Enter migration here
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
from user_friends uf;
$$;

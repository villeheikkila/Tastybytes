--! Previous: sha1:6fc96051ef0ac52259eea44482c70e5cee5e937f
--! Hash: sha1:800ebc7885146d6997ba58c3e16b49ff1d66d4e7

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
  select urs.id, urs.first_name, urs.last_name, urs.username, urs.avatar_url
                      from app_public.friends f
                             left join app_public.users urs
                                       on f.user_id_2 = urs.id or
                                          f.user_id_1 = urs.id;
$$;

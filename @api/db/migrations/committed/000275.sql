--! Previous: sha1:32e33266f77535f8c894db327b19c8af0db59ea4
--! Hash: sha1:5b4d6faf7c6333515cce1cf582ace83d673fc0cf

--! split: 1-current.sql
-- Enter migration here
create function app_public.users_friend_status(u app_public.users)
  returns app_public.friend_status
  language sql
  stable
as
$$
select status from app_public.friends
                 where (user_id_1 = u.id and user_id_2 = app_public.current_user_id()) or
                    (user_id_2 = u.id and user_id_1 = app_public.current_user_id())
$$;

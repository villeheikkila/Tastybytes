--! Previous: sha1:183c602d14e2edafd533bc9da1be82e8c97565f8
--! Hash: sha1:82fcde360a0badc9dd47a215cc5615cdd8f98f55

--! split: 1-current.sql
create or replace function app_public.accept_friend_request(user_id uuid) returns void
  language plpgsql
  security definer
  set search_path to 'pg_catalog', 'public', 'pg_temp'
as
$$
begin
  update app_public.friends
  set (status) = ('accepted')
  where user_id_1 = user_id
    and user_id_2 = app_public.current_user_id();
end;
$$;

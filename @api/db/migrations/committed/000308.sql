--! Previous: sha1:01894dffd7f6a754fbbfc41cf68d11509b81e30f
--! Hash: sha1:51de7c03080978c1272643ee99acf29671c29882

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.users_total_friends(u app_public.users)
  returns int
  language sql
  stable
as
$$
select count(1)
from app_public.friends
where (user_id_1 = u.id
   or user_id_2 = u.id) and status = 'accepted';
$$;

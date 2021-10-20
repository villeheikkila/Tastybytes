--! Previous: sha1:ceb337cd4673d3386cbb905ad59970028ca2ce2b
--! Hash: sha1:385542ff38bd02d0a0603a33454d8667e6928cb7

--! split: 1-current.sql
-- Enter migration here
drop view app_public.current_user_friends;

create view app_public.current_user_friends as
select u.first_name, u.last_name, u.username, u.avatar_url, f.status
from app_public.friends f
left join app_public.users u on (f.user_id_2 = u.id or f.user_id_1 = u.id) and u.id != app_public.current_user_id()
where f.user_id_1 = app_public.current_user_id()
   or f.user_id_2 = app_public.current_user_id();

GRANT SELECT ON TABLE app_public.current_user_friends TO tasted_visitor;

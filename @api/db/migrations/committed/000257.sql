--! Previous: sha1:c4620cc42633200284eecd657b47d363f3b2a5d1
--! Hash: sha1:c863eb8dcd583ba7e74da1429386db35492a66ff

--! split: 1-current.sql
drop view app_public.current_user_friends;

create view app_public.current_user_friends as
select u.first_name, u.last_name, u.username, f.status
from app_public.friends f
left join app_public.users u on f.user_id_2 = app_public.current_user_id() or f.user_id_1 = app_public.current_user_id()
where f.user_id_1 = app_public.current_user_id()
   or f.user_id_2 = app_public.current_user_id();

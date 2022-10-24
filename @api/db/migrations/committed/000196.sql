--! Previous: sha1:47a937a253b6caa26bfca94fec294302ec051006
--! Hash: sha1:654e8e868d16c250d9aa0786eeddc7318e0d6d91

--! split: 1-current.sql
-- Enter migration here
drop policy select_friends_or_public_check_ins on app_public.check_ins;

create policy select_friends on app_public.check_ins for select using ((author_id in ( select app_public.current_user_friends() as current_user_friends)));

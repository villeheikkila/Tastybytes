--! Previous: sha1:9a8113512ed1cb533a2870899c74f89e2e420e4d
--! Hash: sha1:ba0826be6d765de3f248db21a2552d4e23ffa866

--! split: 1-current.sql
-- Enter migration here
create view app_public.activity_feed as
select app_public.check_ins.*
from app_public.check_ins
left join
    app_public.friends on
        app_public.check_ins.author_id = app_public.friends.user_id_2
where app_public.friends.user_id_1 = current_user_id()

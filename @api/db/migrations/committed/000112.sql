--! Previous: sha1:6a52fbef137daa4705a06aa4dbe234d1317800a6
--! Hash: sha1:84f6cbd82791c481508e333462f417ea47ff41ec

--! split: 1-current.sql
-- Enter migration here
create or replace view app_public.activity_feed as
select app_public.check_ins.*
from app_public.check_ins
left join
    app_public.friends on
        app_public.check_ins.author_id = app_public.friends.user_id_2
where
    app_public.friends.user_id_1 = current_user_id()
    or app_public.check_ins.author_id = current_user_id()
order by app_public.check_ins.created_at;

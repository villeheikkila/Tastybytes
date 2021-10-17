--! Previous: sha1:9b11d881f7c35b7921155a684089d0c2758ec9ca
--! Hash: sha1:d65d233bf30683342caf4176113ed972bbfeed8f

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
    or app_public.check_ins.author_id = current_user_id();

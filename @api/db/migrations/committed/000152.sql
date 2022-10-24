--! Previous: sha1:c64d7ca8be7ff7c413bf4f093d8ccc4b12b4bb18
--! Hash: sha1:249bedd9a9e1aa2cc50cb4c8063faafce04ddfbe

--! split: 1-current.sql
-- Enter migration here
create or replace view app_public.activity_feed as
select app_public.check_ins.*
from app_public.check_ins
       left join
     app_public.friends f on
           app_public.check_ins.author_id = f.user_id_2 or
           app_public.check_ins.author_id = f.user_id_1
where f.status = 'accepted'
order by app_public.check_ins.created_at;

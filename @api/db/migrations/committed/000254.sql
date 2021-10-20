--! Previous: sha1:e97d1fe9eec577a8af44ac1003941c8232c51df2
--! Hash: sha1:a529b21e8fce4be4566b138279044c5657c92bbf

--! split: 1-current.sql
create view app_public.current_user_friends as
select *
from app_public.friends f
where f.user_id_1 = app_public.current_user_id()
   or f.user_id_2 = app_public.current_user_id();

--! Previous: sha1:c333c528b87c6debeabe3239ce63b06dbcfa505b
--! Hash: sha1:31f4bb8f8bea023c6bea4fa8701d5676d19cd37e

--! split: 1-current.sql
-- Enter migration here
create or replace view app_public.public_users as
select app_public.users.*
from app_public.users
left join
    app_public.user_settings on
        app_public.users.id = app_public.user_settings.id
where
    app_public.user_settings.is_public = true;

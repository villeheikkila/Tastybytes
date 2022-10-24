--! Previous: sha1:ed704d108e07d82416146fb579591c71bada0231
--! Hash: sha1:f8372139ad3842132c07d033b1a939cf7915c69a

--! split: 1-current.sql
-- Enter migration here
create or replace view app_public.public_users as
select
    app_public.users.*,
    coalesce(app_public.friends.user_id_1 is null, false) as is_friend
from app_public.users
left join
    app_public.user_settings on
        app_public.users.id = app_public.user_settings.id
left join app_public.friends on app_public.friends.user_id_1 = current_user_id()
where
    app_public.user_settings.is_public = true;

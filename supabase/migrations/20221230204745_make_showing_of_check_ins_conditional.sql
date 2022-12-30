alter table "public"."profile_settings" add column "public_profile" boolean not null default true;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__user_can_view_check_in(p_uid uuid, p_check_in_id bigint)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
select exists(select 1
              from check_ins ci
                     left join profile_settings ps on ci.created_by = ps.id
              where p_uid = ci.created_by
                 or (ci.id = p_check_in_id and (ps.public_profile
                or fnc__user_is_friends_with(p_uid, ci.created_by))));
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__user_is_friends_with(p_uid uuid, p_friend_uid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
select exists(select 1
              from friends
              where status = 'accepted' and (user_id_1 = p_uid and user_id_2 = p_friend_uid)
                 or (user_id_2 = p_uid and user_id_1 = p_friend_uid))
$function$
;

create policy "Enable read based on check in's creator's privacy settings"
on "public"."check_ins"
as permissive
for select
to authenticated
using (fnc__user_can_view_check_in(auth.uid(), id));








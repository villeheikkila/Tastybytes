set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__mark_check_in_notification_as_read(p_check_in_id bigint)
 RETURNS SETOF notifications
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
update notifications
set seen_at = now()
where profile_id = auth.uid()
  and (check_in_reaction_id in (select id from check_in_reactions where check_in_id = p_check_in_id) or
       tagged_in_check_in_id in (select id from check_in_tagged_profiles where check_in_id = p_check_in_id))
returning *;
$function$
;



set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__user_can_view_check_in(p_uid uuid, p_check_in_id bigint)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
select exists(select 1
              from check_ins ci
                     left join profiles p on ci.created_by = p.id
              where ci.id = p_check_in_id
                and (p_uid = ci.created_by
                or p.is_private = false
                or fnc__user_is_friends_with(p_uid, ci.created_by)));
$function$
;



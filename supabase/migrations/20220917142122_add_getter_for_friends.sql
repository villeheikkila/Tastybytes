drop function if exists "public"."get_friends"();

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_friends_by_username(p_username text)
 RETURNS SETOF profiles
 LANGUAGE plpgsql
AS $function$
declare
    v_user_id uuid;
begin
    select id
    from profiles
    where username = p_username
    into v_user_id;

    return query (with friend_ids as (select case
                                                 when user_id_1 != v_user_id
                                                     then user_id_1
                                                 else user_id_2 end friend_id
                                      from friends
                                      where status = 'accepted'
                                        and (user_id_1 = v_user_id or user_id_2 = v_user_id))
                  select p.*
                  from friend_ids f
                           left join profiles p on p.id = f.friend_id);
end;
$function$
;



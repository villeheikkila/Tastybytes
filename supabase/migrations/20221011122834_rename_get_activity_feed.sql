drop function if exists "public"."get_activity_feed"();

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_activity_feed()
 RETURNS SETOF check_ins
 LANGUAGE plpgsql
AS $function$
begin
    return query (with friend_ids as (select case
                                                 when user_id_1 != auth.uid()
                                                     then user_id_1
                                                 else user_id_2 end friend_id
                                      from friends
                                      where status = 'accepted'
                                          and user_id_1 = auth.uid()
                                         or user_id_2 = auth.uid())
                  select *
                  from check_ins
                  where created_by = auth.uid()
                     or created_by in (select friend_id from friend_ids));
end;
$function$
;



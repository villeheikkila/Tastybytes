CREATE OR REPLACE FUNCTION public.fnc__get_activity_feed(p_created_after date DEFAULT NULL::date)
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
                                      and (user_id_1 = auth.uid()
                                       or user_id_2 = auth.uid()))
                select c.*
                from check_ins c
                where (p_created_after is null or c.created_at > p_created_after)
                  and (created_by = auth.uid()
                  or created_by in (select friend_id from friend_ids)))
    order by created_at desc;
end;
$function$
;
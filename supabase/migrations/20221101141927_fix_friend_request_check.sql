set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__friend_request_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_already_exists bool := false;
begin
  select exists(select 1
                from friends f
                where (f.user_id_1 = new.user_id_1 and f.user_id_1 = new.user_id_2)
                   or (f.user_id_1 = new.user_id_2 and f.user_id_1 = new.user_id_1))
  into v_already_exists;
  if v_already_exists then
    raise exception 'users are already friends with each other' using errcode = 'already_friends';
  end if;

  -- make sure that the sender is the current user and that the profiles can't be updated later
  new.user_id_1 = (case when TG_OP = 'INSERT' then auth.uid() else old.user_id_1 end);
  new.user_id_2 = (case when TG_OP = 'INSERT' then new.user_id_2 else old.user_id_2 end);
  return new;
end;
$function$
;



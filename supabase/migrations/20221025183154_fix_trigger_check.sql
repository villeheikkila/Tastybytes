set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__forbid_send_messages_too_often()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
DECLARE
  v_last_message timestamptz;
begin
  select created_at
  from check_in_comments
  where created_by = auth.uid()
  order by created_at desc
  limit 1
  into v_last_message;

  if v_last_message + interval '10 seconds' > now() then
    raise exception 'user is only allowed to send a comment every 10 seconds' using errcode = 'too_rapid_commenting';
  else
    return new;
  end if;
end;
$function$
;



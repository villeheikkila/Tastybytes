set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__delete_check_in_comment_as_moderator(p_check_in_comment_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__current_user_has_permission('can_delete_comments') then
    delete from check_in_comments where id = p_check_in_comment_id;
  end if;
end;
$function$
;


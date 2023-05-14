set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__delete_check_in_as_moderator(p_check_in_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__current_user_has_permission('can_delete_check_ins_as_moderator') then
    if (select fnc__is_protected(created_by) from check_ins where id = p_check_in_id) is true then
      raise exception E'check ins can''t be removed from protected users';
    end if;
    delete from check_ins where id = p_check_in_id;
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__is_protected(p_uid uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
select exists(select 1
              from roles r
                     left join profiles_roles pr on r.id = pr.role_id
              where pr.profile_id = p_uid
                and r.name in ('admin', 'moderator'))
$function$
;

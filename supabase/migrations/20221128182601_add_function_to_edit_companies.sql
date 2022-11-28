
set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__update_check_in(p_company_id bigint, p_name text)
 RETURNS SETOF companies
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__current_user_has_permission('can_edit_companies') is false then
    raise exception E'You don\'t have permission to edit companies';
  end if;

  update companies set name = p_name where id = p_company_id returning *;
end
$function$
;



set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__soft_delete_check_in_reaction(p_check_in_reaction_id bigint)
 RETURNS SETOF check_in_reactions
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
update check_in_reactions
set deleted_at = now()
where id = p_check_in_reaction_id
  and created_by = auth.uid()
returning *;
$function$
;



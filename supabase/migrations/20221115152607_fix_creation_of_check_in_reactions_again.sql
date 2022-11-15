set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_check_in_reaction(p_check_in_id bigint)
 RETURNS SETOF check_in_reactions
 LANGUAGE plpgsql
AS $function$
declare
  v_created_check_in_reaction_id bigint;
begin
  select id from check_in_reactions where check_in_id = p_check_in_id and created_by = auth.uid() into v_created_check_in_reaction_id;

  if v_created_check_in_reaction_id is null then
    insert into check_in_reactions (check_in_id, created_by)
    values (p_check_in_id, auth.uid())
    returning id
    into v_created_check_in_reaction_id;
  else
    update check_in_reactions set deleted_at = null where id = v_created_check_in_reaction_id;
  end if;

  return query (select * from check_in_reactions where id = v_created_check_in_reaction_id);
end;
$function$
;



set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.delete_notification_on_reaction_delete()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if old.deleted_at is null and new.deleted_at is not null then
    delete from notifications where check_in_reaction_id = old.id;
  end if;
  return new;
end;
$function$
;

CREATE TRIGGER delete_notification_trigger AFTER UPDATE OF deleted_at ON public.check_in_reactions FOR EACH ROW WHEN ((old.deleted_at IS DISTINCT FROM new.deleted_at)) EXECUTE FUNCTION delete_notification_on_reaction_delete();



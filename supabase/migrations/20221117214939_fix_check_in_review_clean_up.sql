set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__clean_up_check_in()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
  declare
    v_trimmed_review text;
begin
  -- minimum rating is 0.25, 0 is used to mark the check-in not having a rating
  if new.rating < 0.25 then
    new.rating = null;
  end if;

  select trim(new.review) into v_trimmed_review;

  if new.review is null or length(v_trimmed_review) = 0 then
    new.review = null;
  else
    new.review = v_trimmed_review;
  end if;

  return new;
end;
$function$
;



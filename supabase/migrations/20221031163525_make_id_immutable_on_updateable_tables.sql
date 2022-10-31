drop policy "Enable update for admin" on "public"."companies";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__make_id_immutable()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
BEGIN
  NEW.id := OLD.id;
  RETURN NEW;
END;
$function$
;

CREATE TRIGGER make_id_immutable BEFORE UPDATE ON public.check_in_comments FOR EACH ROW EXECUTE FUNCTION tg__make_id_immutable();

CREATE TRIGGER make_id_immutable BEFORE UPDATE ON public.check_ins FOR EACH ROW EXECUTE FUNCTION tg__make_id_immutable();

CREATE TRIGGER make_id_immutable BEFORE UPDATE ON public.friends FOR EACH ROW EXECUTE FUNCTION tg__make_id_immutable();

CREATE TRIGGER make_id_immutable BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION tg__make_id_immutable();



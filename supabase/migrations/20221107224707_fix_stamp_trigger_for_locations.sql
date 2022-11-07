drop trigger if exists "stamp_created_by" on "public"."locations";

CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



drop trigger if exists "stamp_created_by" on "public"."sub_brands";

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.subcategories FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.sub_brands FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



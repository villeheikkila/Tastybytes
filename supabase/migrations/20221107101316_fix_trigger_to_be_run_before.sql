drop trigger if exists "check_subcategory_constraint" on "public"."products_subcategories";

CREATE TRIGGER check_subcategory_constraint BEFORE INSERT OR UPDATE ON public.products_subcategories FOR EACH ROW EXECUTE FUNCTION tg__check_subcategory_constraint();



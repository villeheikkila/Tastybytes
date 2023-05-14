set check_function_bodies = off;

CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.product_edit_suggestions FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



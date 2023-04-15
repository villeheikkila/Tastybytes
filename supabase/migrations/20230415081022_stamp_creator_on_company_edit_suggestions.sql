CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.company_edit_suggestions FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.reports FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



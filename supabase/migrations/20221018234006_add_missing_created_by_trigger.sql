CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.companies FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



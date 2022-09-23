drop trigger if exists "on_insert" on "public"."brands";

drop trigger if exists "on_insert" on "public"."check_in_comments";

drop trigger if exists "on_insert" on "public"."check_in_reactions";

drop trigger if exists "on_insert" on "public"."check_ins";

drop trigger if exists "on_insert" on "public"."friends";

drop trigger if exists "on_insert" on "public"."products";

drop trigger if exists "on_insert" on "public"."sub-brands";

CREATE TRIGGER stamp_created_by AFTER INSERT ON public.brands FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by AFTER INSERT ON public.check_in_comments FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by AFTER INSERT ON public.check_in_reactions FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by AFTER INSERT ON public.check_ins FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by AFTER INSERT OR UPDATE ON public.friends FOR EACH ROW EXECUTE FUNCTION tg__create_friend_request();

CREATE TRIGGER stamp_created_by AFTER INSERT ON public.products FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by AFTER INSERT ON public."sub-brands" FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



drop trigger if exists "stamp_created_by" on "public"."brands";

drop trigger if exists "stamp_created_by" on "public"."check_in_comments";

drop trigger if exists "stamp_created_by" on "public"."check_in_reactions";

drop trigger if exists "stamp_created_by" on "public"."check_ins";

drop trigger if exists "stamp_created_by" on "public"."friends";

drop trigger if exists "stamp_created_by" on "public"."products";

alter table "public"."product_variants" add column "created_by" uuid;

alter table "public"."product_variants" add constraint "product_variants_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL not valid;

alter table "public"."product_variants" validate constraint "product_variants_created_by_fkey";

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.product_variants FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.products_subcategories FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.brands FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.check_in_comments FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.check_in_reactions FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.check_ins FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.friends FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_created_by BEFORE INSERT ON public.products FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



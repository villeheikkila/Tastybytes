drop trigger if exists "make_id_immutable" on "public"."profiles";

CREATE TRIGGER always_update_as_current_user BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION tg__use_current_user_profile_id_as_id();



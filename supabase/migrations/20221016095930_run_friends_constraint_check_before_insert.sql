drop trigger if exists "on_friend_request_update" on "public"."friends";

CREATE TRIGGER on_friend_request_update BEFORE INSERT OR UPDATE ON public.friends FOR EACH ROW EXECUTE FUNCTION tg__check_friend_status_transition();



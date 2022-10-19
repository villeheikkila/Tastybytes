drop trigger if exists "stamp_created_by" on "public"."friends";

CREATE TRIGGER stamp_sender BEFORE INSERT ON public.friends FOR EACH ROW EXECUTE FUNCTION tg__create_friend_request();



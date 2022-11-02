alter table "public"."profile_settings" enable row level security;

create policy "Enable read access only to the owner"
on "public"."profile_settings"
as permissive
for select
to authenticated
using ((id = auth.uid()));


create policy "Enable update for the owner"
on "public"."profile_settings"
as permissive
for update
to authenticated
using ((id = auth.uid()))
with check ((id = auth.uid()));


CREATE TRIGGER make_id_immutable BEFORE UPDATE ON public.profile_settings FOR EACH ROW EXECUTE FUNCTION tg__make_id_immutable();



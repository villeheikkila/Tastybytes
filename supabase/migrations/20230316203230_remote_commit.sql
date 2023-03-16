alter table "storage"."objects" drop constraint "objects_owner_fkey";

alter table "storage"."objects" add constraint "objects_owner_fkey" FOREIGN KEY (owner) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "storage"."objects" validate constraint "objects_owner_fkey";

create policy "Give read and inset access to logos 1peuqw_0"
on "storage"."objects"
as permissive
for select
to authenticated
using (((bucket_id = 'logos'::text) AND (storage.extension(name) = 'jpeg'::text)));


create policy "Give read and inset access to logos 1peuqw_1"
on "storage"."objects"
as permissive
for insert
to authenticated
with check (((bucket_id = 'logos'::text) AND (storage.extension(name) = 'jpeg'::text) AND fnc__has_permission(auth.uid(), 'can_add_company_logo'::text)));




drop policy "Enable delete only for admin" on "public"."products_subcategories";

alter table "public"."permissions" enable row level security;

alter table "public"."profiles_roles" enable row level security;

alter table "public"."roles_permissions" enable row level security;

create policy "Enable select for authenticated users only"
on "public"."permissions"
as permissive
for select
to authenticated
using (true);


create policy "Enable delete for users with can_delete_products permission"
on "public"."products"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM (((permissions p
     LEFT JOIN roles_permissions rp ON ((rp.permission_id = p.id)))
     LEFT JOIN roles r ON ((rp.role_id = r.id)))
     LEFT JOIN profiles_roles pr ON ((r.id = pr.role_id)))
  WHERE ((pr.profile_id = auth.uid()) AND (p.name = 'can_delete_products'::text)))));


create policy "Enable select for authenticated users only"
on "public"."profiles_roles"
as permissive
for select
to authenticated
using (true);


create policy "Enable select for authenticated users only"
on "public"."roles_permissions"
as permissive
for select
to authenticated
using (true);




drop policy "Enable insert for authenticated users only" on "public"."categories";

drop policy "Enable delete for users based on creator" on "public"."check_ins";

drop policy "Enable update for own check-ins" on "public"."check_ins";

drop policy "Users can insert their own profile." on "public"."profiles";

drop policy "Enable insert for authenticated users only" on "public"."reactions";

drop policy "Enable delete for both sides of friend status" on "public"."friends";

drop policy "Enable update for both sides of friend status unless blocked" on "public"."friends";

create policy "Enable delete for admin"
on "public"."brands"
as permissive
for delete
to public
using (fnc__is_admin(auth.uid()));


create policy "Enable update for admin"
on "public"."brands"
as permissive
for update
to public
using (fnc__is_admin(auth.uid()))
with check (fnc__is_admin(auth.uid()));


create policy "Enable delete for the creator of the check in"
on "public"."check_in_flavors"
as permissive
for delete
to public
using ((EXISTS ( SELECT 1
   FROM check_ins ci
  WHERE ((ci.id = check_in_flavors.check_in_id) AND (ci.created_by = auth.uid())))));


create policy "Enable insert for creator of the check in"
on "public"."check_in_flavors"
as permissive
for insert
to authenticated
with check ((EXISTS ( SELECT 1
   FROM check_ins ci
  WHERE ((ci.id = check_in_flavors.check_in_id) AND (ci.created_by = auth.uid())))));


create policy "Enable delete for the creator"
on "public"."check_in_reactions"
as permissive
for delete
to public
using ((auth.uid() = created_by));


create policy "Enable delete for creator of the check in"
on "public"."check_in_tagged_profiles"
as permissive
for delete
to public
using ((EXISTS ( SELECT 1
   FROM check_ins ci
  WHERE ((ci.id = check_in_tagged_profiles.check_in_id) AND (ci.created_by = auth.uid())))));


create policy "Enable insert for creator of  the check in"
on "public"."check_in_tagged_profiles"
as permissive
for insert
to authenticated
with check ((EXISTS ( SELECT 1
   FROM check_ins ci
  WHERE ((ci.id = check_in_tagged_profiles.check_in_id) AND (ci.created_by = auth.uid())))));


create policy "Enable delete for the creator"
on "public"."check_ins"
as permissive
for delete
to public
using ((auth.uid() = created_by));


create policy "Enable update for the creaotr"
on "public"."check_ins"
as permissive
for update
to public
using ((created_by = auth.uid()));


create policy "Enable delete for admin"
on "public"."companies"
as permissive
for delete
to public
using (fnc__is_admin(auth.uid()));


create policy "Enable update for admin"
on "public"."companies"
as permissive
for update
to public
using (fnc__is_admin(auth.uid()))
with check (fnc__is_admin(auth.uid()));


create policy "Enable insert for authenticated users only"
on "public"."locations"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable delete for admin"
on "public"."products"
as permissive
for delete
to public
using (fnc__is_admin(auth.uid()));


create policy "Enable update only for admin"
on "public"."products"
as permissive
for update
to public
using (fnc__is_admin(auth.uid()))
with check (fnc__is_admin(auth.uid()));


create policy "Allow update only for admin"
on "public"."products_subcategories"
as permissive
for update
to public
using (fnc__is_admin(auth.uid()));


create policy "Enable delete only for admin"
on "public"."products_subcategories"
as permissive
for delete
to public
using (fnc__is_admin(auth.uid()));


create policy "Enable insert for authenticated users only"
on "public"."products_subcategories"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."products_subcategories"
as permissive
for select
to authenticated
using (true);


create policy "Enable delete only for admin"
on "public"."sub-brands"
as permissive
for delete
to public
using (fnc__is_admin(auth.uid()));


create policy "Enable insert for authenticated users only"
on "public"."sub-brands"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable update only for admin"
on "public"."sub-brands"
as permissive
for update
to public
using (fnc__is_admin(auth.uid()))
with check (fnc__is_admin(auth.uid()));


create policy "Enable delete for both sides of friend status"
on "public"."friends"
as permissive
for delete
to public
using ((((user_id_1 = auth.uid()) OR (user_id_2 = auth.uid())) AND ((status <> 'blocked'::friend_status) OR (blocked_by = auth.uid()))));


create policy "Enable update for both sides of friend status unless blocked"
on "public"."friends"
as permissive
for update
to public
using ((((user_id_1 = auth.uid()) AND ((status <> 'blocked'::friend_status) OR (blocked_by = auth.uid()))) OR ((user_id_2 = auth.uid()) AND ((status <> 'blocked'::friend_status) OR (blocked_by = auth.uid())))));




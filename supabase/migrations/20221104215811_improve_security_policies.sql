drop policy "Brands are viewable by everyone." on "public"."brands";

drop policy "Do not allow deleting verified" on "public"."brands";

drop policy "Enable delete for users based on user_id" on "public"."check_in_comments";

drop policy "Do not allow deleting verified" on "public"."companies";

drop policy "Do not allow deleting verified" on "public"."product_variants";

drop policy "Do not allow deleting verified products" on "public"."products";

drop policy "Do not allow deleting verified" on "public"."products_subcategories";

drop policy "Do not allow deleting verified" on "public"."sub_brands";

drop policy "Do not allow deleting verified" on "public"."subcategories";

drop policy "Enable delete for creator" on "public"."brand_edit_suggestions";

drop policy "Enable delete for users with permission" on "public"."brands";

drop policy "Enable update for creator of comment" on "public"."check_in_comments";

drop policy "Enable delete for the creator of the check in" on "public"."check_in_flavors";

drop policy "Enable delete for the creator" on "public"."check_in_reactions";

drop policy "Enable delete for creator of the check in" on "public"."check_in_tagged_profiles";

drop policy "Enable delete for the creator" on "public"."check_ins";

drop policy "Enable update for the creator" on "public"."check_ins";

drop policy "Users can delete own profile." on "public"."profiles";

drop policy "Users can update own profile." on "public"."profiles";

drop policy "Enable delete for creator" on "public"."sub_brand_edit_suggestion";

create policy "Forbid deleting verified"
on "public"."brands"
as restrictive
for delete
to authenticated
using ((is_verified = false));


create policy "Enable delete for creator"
on "public"."check_in_comments"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));


create policy "Forbid deleting verified"
on "public"."companies"
as restrictive
for delete
to authenticated
using ((is_verified = false));


create policy "Forbid deleting verified"
on "public"."product_variants"
as restrictive
for delete
to authenticated
using ((is_verified = false));


create policy "Forbid deleting verified"
on "public"."products"
as restrictive
for delete
to authenticated
using ((is_verified = false));


create policy "Forbid deleting verified"
on "public"."sub_brands"
as restrictive
for delete
to authenticated
using ((is_verified = false));


create policy "Forbid deleting verified"
on "public"."subcategories"
as restrictive
for delete
to authenticated
using ((is_verified = false));


create policy "Enable delete for creator"
on "public"."brand_edit_suggestions"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));


create policy "Enable delete for users with permission"
on "public"."brands"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_brands'::text));


create policy "Enable update for creator of comment"
on "public"."check_in_comments"
as permissive
for update
to authenticated
using ((auth.uid() = created_by))
with check ((auth.uid() = created_by));


create policy "Enable delete for the creator of the check in"
on "public"."check_in_flavors"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM check_ins ci
  WHERE ((ci.id = check_in_flavors.check_in_id) AND (ci.created_by = auth.uid())))));


create policy "Enable delete for the creator"
on "public"."check_in_reactions"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));


create policy "Enable delete for creator of the check in"
on "public"."check_in_tagged_profiles"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM check_ins ci
  WHERE ((ci.id = check_in_tagged_profiles.check_in_id) AND (ci.created_by = auth.uid())))));


create policy "Enable delete for the creator"
on "public"."check_ins"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));


create policy "Enable update for the creator"
on "public"."check_ins"
as permissive
for update
to authenticated
using ((created_by = auth.uid()));


create policy "Users can delete own profile."
on "public"."profiles"
as permissive
for delete
to authenticated
using ((auth.uid() = id));


create policy "Users can update own profile."
on "public"."profiles"
as permissive
for update
to authenticated
using ((auth.uid() = id));


create policy "Enable delete for creator"
on "public"."sub_brand_edit_suggestion"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));




drop policy "Enable delete for creator" on "public"."company_edit_suggestions";

drop policy "Enable delete for both sides of friend status" on "public"."friends";

drop policy "Enable update for both sides of friend status " on "public"."friends";

drop policy "Enable delete for the owner" on "public"."notifications";

drop policy "Enable delete for creator" on "public"."product_edit_suggestion_subcategories";

drop policy "Enable delete for creator" on "public"."product_edit_suggestions";

create policy "Enable delete for creator"
on "public"."company_edit_suggestions"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));


create policy "Enable delete for both sides of friend status"
on "public"."friends"
as permissive
for delete
to authenticated
using ((((user_id_1 = auth.uid()) OR (user_id_2 = auth.uid())) AND ((status <> 'blocked'::enum__friend_status) OR (blocked_by = auth.uid()))));


create policy "Enable update for both sides of friend status "
on "public"."friends"
as permissive
for update
to authenticated
using (((user_id_1 = auth.uid()) OR (user_id_2 = auth.uid())))
with check (((user_id_1 = auth.uid()) OR (user_id_2 = auth.uid())));


create policy "Enable delete for the owner"
on "public"."notifications"
as permissive
for delete
to authenticated
using ((auth.uid() = profile_id));


create policy "Enable delete for creator"
on "public"."product_edit_suggestion_subcategories"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM (product_edit_suggestion_subcategories pess
     LEFT JOIN product_edit_suggestions pes ON ((pess.product_edit_suggestion_id = pes.id)))
  WHERE (pes.created_by = auth.uid()))));


create policy "Enable delete for creator"
on "public"."product_edit_suggestions"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));




CREATE UNIQUE INDEX unique_company_edit_suggestion ON public.company_edit_suggestions USING btree (company_id, name, created_by);

alter table "public"."company_edit_suggestions" add constraint "unique_company_edit_suggestion" UNIQUE using index "unique_company_edit_suggestion";



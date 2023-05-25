drop trigger if exists "stamp_created_by" on "public"."product_duplicate_suggestion";

drop policy "Enable delete for creator" on "public"."product_duplicate_suggestion";

drop policy "Enable insert for authenticated users only" on "public"."product_duplicate_suggestion";

drop policy "Enable read access for creator" on "public"."product_duplicate_suggestion";

alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_created_by_fkey";

alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_duplicate_of_product_id_fkey";

alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_product_id_fkey";

alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_pkey";

drop index if exists "public"."product_duplicate_suggestion_pkey";

drop table "public"."product_duplicate_suggestion";

create table "public"."product_duplicate_suggestions" (
    "product_id" bigint not null,
    "duplicate_of_product_id" bigint not null,
    "created_by" uuid not null,
    "created_at" timestamp with time zone not null default now()
);


alter table "public"."product_duplicate_suggestions" enable row level security;

CREATE UNIQUE INDEX product_duplicate_suggestion_pkey ON public.product_duplicate_suggestions USING btree (product_id, duplicate_of_product_id, created_by);

alter table "public"."product_duplicate_suggestions" add constraint "product_duplicate_suggestion_pkey" PRIMARY KEY using index "product_duplicate_suggestion_pkey";

alter table "public"."product_duplicate_suggestions" add constraint "product_duplicate_suggestion_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."product_duplicate_suggestions" validate constraint "product_duplicate_suggestion_created_by_fkey";

alter table "public"."product_duplicate_suggestions" add constraint "product_duplicate_suggestion_duplicate_of_product_id_fkey" FOREIGN KEY (duplicate_of_product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."product_duplicate_suggestions" validate constraint "product_duplicate_suggestion_duplicate_of_product_id_fkey";

alter table "public"."product_duplicate_suggestions" add constraint "product_duplicate_suggestion_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."product_duplicate_suggestions" validate constraint "product_duplicate_suggestion_product_id_fkey";

create policy "Enable delete for creator"
on "public"."product_duplicate_suggestions"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));


create policy "Enable insert for authenticated users only"
on "public"."product_duplicate_suggestions"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for creator"
on "public"."product_duplicate_suggestions"
as permissive
for select
to authenticated
using ((created_by = auth.uid()));


CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.product_duplicate_suggestions FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();



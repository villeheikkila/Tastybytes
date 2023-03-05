create table "public"."product_duplicate_suggestion" (
    "product_id" bigint not null,
    "duplicate_of_product_id" bigint not null,
    "created_by" uuid,
    "created_at" timestamp with time zone not null default now()
);


alter table "public"."product_duplicate_suggestion" enable row level security;

CREATE UNIQUE INDEX product_duplicate_suggestion_pkey ON public.product_duplicate_suggestion USING btree (product_id, duplicate_of_product_id);

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_pkey" PRIMARY KEY using index "product_duplicate_suggestion_pkey";

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL not valid;

alter table "public"."product_duplicate_suggestion" validate constraint "product_duplicate_suggestion_created_by_fkey";

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_duplicate_of_product_id_fkey" FOREIGN KEY (duplicate_of_product_id) REFERENCES products(id) not valid;

alter table "public"."product_duplicate_suggestion" validate constraint "product_duplicate_suggestion_duplicate_of_product_id_fkey";

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) not valid;

alter table "public"."product_duplicate_suggestion" validate constraint "product_duplicate_suggestion_product_id_fkey";

create policy "Enable insert for authenticated users only"
on "public"."product_duplicate_suggestion"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."product_duplicate_suggestion"
as permissive
for select
to authenticated
using (true);




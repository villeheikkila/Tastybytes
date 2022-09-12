create table "public"."migration_table" (
    "id" numeric not null,
    "category" text,
    "subcategory" text,
    "manufacturer" text,
    "brand_owner" text,
    "brand" text,
    "sub-brand" text,
    "flavour" text,
    "description" text,
    "rating" text,
    "location" text,
    "image" text
);


alter table "public"."check_ins" add column "migration_id" numeric;

CREATE UNIQUE INDEX check_ins_migration_id_key ON public.check_ins USING btree (migration_id);

CREATE UNIQUE INDEX migration_table_id_key ON public.migration_table USING btree (id);

alter table "public"."check_ins" add constraint "check_ins_migration_id_fkey" FOREIGN KEY (migration_id) REFERENCES migration_table(id) not valid;

alter table "public"."check_ins" validate constraint "check_ins_migration_id_fkey";

alter table "public"."check_ins" add constraint "check_ins_migration_id_key" UNIQUE using index "check_ins_migration_id_key";

alter table "public"."migration_table" add constraint "migration_table_id_key" UNIQUE using index "migration_table_id_key";



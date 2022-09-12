CREATE UNIQUE INDEX migration_table_pkey ON public.migration_table USING btree (id);

alter table "public"."migration_table" add constraint "migration_table_pkey" PRIMARY KEY using index "migration_table_pkey";



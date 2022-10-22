alter table "public"."companies" add column "subsidiary_of" bigint;

alter table "public"."companies" add constraint "companies_subsidiary_of_fkey" FOREIGN KEY (subsidiary_of) REFERENCES companies(id) ON DELETE SET NULL not valid;

alter table "public"."companies" validate constraint "companies_subsidiary_of_fkey";



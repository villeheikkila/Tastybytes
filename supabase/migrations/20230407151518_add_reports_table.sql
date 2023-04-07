create sequence "public"."reports_id_seq";

create table "public"."reports" (
    "id" bigint not null default nextval('reports_id_seq'::regclass),
    "message" text,
    "created_by" uuid,
    "created_at" timestamp with time zone not null default now(),
    "check_in_id" bigint,
    "product_id" bigint,
    "company_id" bigint,
    "check_in_comment_id" bigint,
    "brand_id" bigint,
    "sub_brand_id" bigint
);


alter sequence "public"."reports_id_seq" owned by "public"."reports"."id";

CREATE UNIQUE INDEX reports_pkey ON public.reports USING btree (id);

alter table "public"."reports" add constraint "reports_pkey" PRIMARY KEY using index "reports_pkey";

alter table "public"."reports" add constraint "reports_brand_id_fkey" FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE not valid;

alter table "public"."reports" validate constraint "reports_brand_id_fkey";

alter table "public"."reports" add constraint "reports_check_in_comment_id_fkey" FOREIGN KEY (check_in_comment_id) REFERENCES check_in_comments(id) ON DELETE CASCADE not valid;

alter table "public"."reports" validate constraint "reports_check_in_comment_id_fkey";

alter table "public"."reports" add constraint "reports_check_in_id_fkey" FOREIGN KEY (check_in_id) REFERENCES check_ins(id) ON DELETE CASCADE not valid;

alter table "public"."reports" validate constraint "reports_check_in_id_fkey";

alter table "public"."reports" add constraint "reports_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."reports" validate constraint "reports_company_id_fkey";

alter table "public"."reports" add constraint "reports_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."reports" validate constraint "reports_created_by_fkey";

alter table "public"."reports" add constraint "reports_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."reports" validate constraint "reports_product_id_fkey";

alter table "public"."reports" add constraint "reports_sub_brand_id_fkey" FOREIGN KEY (sub_brand_id) REFERENCES sub_brands(id) ON DELETE CASCADE not valid;

alter table "public"."reports" validate constraint "reports_sub_brand_id_fkey";



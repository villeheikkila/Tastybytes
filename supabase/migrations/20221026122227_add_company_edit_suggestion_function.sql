create sequence "public"."brand_edit_suggestions_id_seq";

create sequence "public"."company_edit_suggestions_id_seq";

create sequence "public"."sub_brand_edit_suggestion_id_seq";

create table "public"."brand_edit_suggestions" (
    "id" bigint not null default nextval('brand_edit_suggestions_id_seq'::regclass),
    "brand_id" bigint not null,
    "name" text,
    "brand_owner_id" bigint,
    "created_by" uuid not null,
    "created_at" timestamp with time zone not null default now()
);


create table "public"."company_edit_suggestions" (
    "id" bigint not null default nextval('company_edit_suggestions_id_seq'::regclass),
    "company_id" bigint not null,
    "name" text,
    "logo_url" text,
    "created_by" uuid not null,
    "created_at" timestamp with time zone not null default now()
);


create table "public"."sub_brand_edit_suggestion" (
    "id" bigint not null default nextval('sub_brand_edit_suggestion_id_seq'::regclass),
    "sub_brand_id" bigint not null,
    "name" text,
    "brand_id" bigint,
    "created_by" uuid not null,
    "created_at" timestamp with time zone not null default now()
);


alter sequence "public"."brand_edit_suggestions_id_seq" owned by "public"."brand_edit_suggestions"."id";

alter sequence "public"."company_edit_suggestions_id_seq" owned by "public"."company_edit_suggestions"."id";

alter sequence "public"."sub_brand_edit_suggestion_id_seq" owned by "public"."sub_brand_edit_suggestion"."id";

CREATE UNIQUE INDEX brand_edit_suggestions_pkey ON public.brand_edit_suggestions USING btree (id);

CREATE UNIQUE INDEX company_edit_suggestions_pkey ON public.company_edit_suggestions USING btree (id);

CREATE UNIQUE INDEX sub_brand_edit_suggestion_pkey ON public.sub_brand_edit_suggestion USING btree (id);

alter table "public"."brand_edit_suggestions" add constraint "brand_edit_suggestions_pkey" PRIMARY KEY using index "brand_edit_suggestions_pkey";

alter table "public"."company_edit_suggestions" add constraint "company_edit_suggestions_pkey" PRIMARY KEY using index "company_edit_suggestions_pkey";

alter table "public"."sub_brand_edit_suggestion" add constraint "sub_brand_edit_suggestion_pkey" PRIMARY KEY using index "sub_brand_edit_suggestion_pkey";

alter table "public"."brand_edit_suggestions" add constraint "brand_edit_suggestions_brand_id_fkey" FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE not valid;

alter table "public"."brand_edit_suggestions" validate constraint "brand_edit_suggestions_brand_id_fkey";

alter table "public"."brand_edit_suggestions" add constraint "brand_edit_suggestions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."brand_edit_suggestions" validate constraint "brand_edit_suggestions_created_by_fkey";

alter table "public"."company_edit_suggestions" add constraint "company_edit_suggestions_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."company_edit_suggestions" validate constraint "company_edit_suggestions_company_id_fkey";

alter table "public"."company_edit_suggestions" add constraint "company_edit_suggestions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."company_edit_suggestions" validate constraint "company_edit_suggestions_created_by_fkey";

alter table "public"."sub_brand_edit_suggestion" add constraint "sub_brand_edit_suggestion_brand_id_fkey" FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE not valid;

alter table "public"."sub_brand_edit_suggestion" validate constraint "sub_brand_edit_suggestion_brand_id_fkey";

alter table "public"."sub_brand_edit_suggestion" add constraint "sub_brand_edit_suggestion_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."sub_brand_edit_suggestion" validate constraint "sub_brand_edit_suggestion_created_by_fkey";

alter table "public"."sub_brand_edit_suggestion" add constraint "sub_brand_edit_suggestion_sub_brand_id_fkey" FOREIGN KEY (sub_brand_id) REFERENCES sub_brands(id) ON DELETE CASCADE not valid;

alter table "public"."sub_brand_edit_suggestion" validate constraint "sub_brand_edit_suggestion_sub_brand_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_company_edit_suggestion(p_company_id bigint, p_name text, p_logo_url text)
 RETURNS SETOF company_edit_suggestions
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_company_edit_suggestion_id bigint;
  v_changed_name               text;
  v_changed_logo_url           text;
  v_current_company            companies%ROWTYPE;
BEGIN
  select * from companies where id = p_company_id into v_current_company;

  if v_current_company.name != p_name then
    v_changed_name = p_name;
  end if;

  if v_current_company.name != p_logo_url then
    v_changed_logo_url = p_logo_url;
  end if;

  insert into company_edit_suggestions (company_id, name, logo_url, created_by)
  values (p_company_id, v_changed_name, v_changed_logo_url, auth.uid())
  returning id into v_company_edit_suggestion_id;

  return query (select *
                from company_edit_suggestions
                where id = v_company_edit_suggestion_id);
END

$function$
;

CREATE OR REPLACE FUNCTION public.fnc__create_product_edit_suggestion(p_product_id bigint, p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_sub_brand_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF product_edit_suggestions
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_product_edit_suggestion_id bigint;
  v_changed_name               text;
  v_changed_description        text;
  v_changed_category_id        bigint;
  v_changed_sub_brand_id       bigint;
  v_current_product            products%ROWTYPE;
BEGIN
  select * from products where id = p_product_id into v_current_product;

  if v_current_product.name != p_name then
    v_changed_name = p_name;
  end if;

  if v_current_product.name != p_description then
    v_changed_description = p_description;
  end if;

  if v_current_product.description != p_description then
    v_changed_description = p_description;
  end if;

  if v_current_product.category_id != p_category_id then
    v_changed_category_id = p_category_id;
  end if;

  if v_current_product.sub_brand_id != p_sub_brand_id then
    v_changed_sub_brand_id = p_sub_brand_id;
  end if;

  insert into product_edit_suggestions (product_id, name, description, category_id, sub_brand_id, created_by)
  values (p_product_id, v_changed_name, v_changed_description, v_changed_category_id, v_changed_sub_brand_id,
          auth.uid())
  returning id into v_product_edit_suggestion_id;

  with subcategories_for_product as (select v_product_edit_suggestion_id product_edit_suggestion_id,
                                            unnest(p_sub_category_ids)   subcategory_id),
       current_subcategories as (select subcategory_id from products_subcategories where product_id = p_product_id),
       delete_subcategories as (select o.subcategory_id
                                from current_subcategories o
                                       left join subcategories_for_product n on n.subcategory_id = o.subcategory_id
                                where n is null),
       add_subcategories as (select n.subcategory_id
                             from subcategories_for_product n
                                    left join current_subcategories o on o.subcategory_id is null
                             where o.subcategory_id is null),
       combined as (select subcategory_id, true delete
                    from delete_subcategories
                    union all
                    select subcategory_id, false
                    from add_subcategories)
  insert
  into product_edit_suggestion_subcategories (product_edit_suggestion_id, subcategory_id, delete)
  select v_product_edit_suggestion_id product_edit_suggestion_id, subcategory_id, delete
  from combined;

  return query (select *
                from product_edit_suggestions
                where id = v_product_edit_suggestion_id);
END

$function$
;



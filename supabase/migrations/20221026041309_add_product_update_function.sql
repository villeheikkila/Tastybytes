create sequence "public"."product_edit_suggestion_subcategories_id_seq";

create sequence "public"."product_edit_suggestions_id_seq";

create table "public"."product_edit_suggestion_subcategories" (
    "id" bigint not null default nextval('product_edit_suggestion_subcategories_id_seq'::regclass),
    "product_edit_suggestion_id" bigint not null,
    "subcategory_id" bigint not null,
    "delete" boolean not null default false
);


create table "public"."product_edit_suggestions" (
    "id" bigint not null default nextval('product_edit_suggestions_id_seq'::regclass),
    "product_id" bigint not null,
    "name" text,
    "description" text,
    "category_id" bigint,
    "sub_brand_id" bigint,
    "created_at" timestamp with time zone not null default now(),
    "created_by" uuid
);


alter sequence "public"."product_edit_suggestion_subcategories_id_seq" owned by "public"."product_edit_suggestion_subcategories"."id";

alter sequence "public"."product_edit_suggestions_id_seq" owned by "public"."product_edit_suggestions"."id";

CREATE UNIQUE INDEX product_edit_suggestion_subcategories_pkey ON public.product_edit_suggestion_subcategories USING btree (id);

CREATE UNIQUE INDEX product_edit_suggestions_pkey ON public.product_edit_suggestions USING btree (id);

alter table "public"."product_edit_suggestion_subcategories" add constraint "product_edit_suggestion_subcategories_pkey" PRIMARY KEY using index "product_edit_suggestion_subcategories_pkey";

alter table "public"."product_edit_suggestions" add constraint "product_edit_suggestions_pkey" PRIMARY KEY using index "product_edit_suggestions_pkey";

alter table "public"."product_edit_suggestion_subcategories" add constraint "product_edit_suggestion_subcate_product_edit_suggestion_id_fkey" FOREIGN KEY (product_edit_suggestion_id) REFERENCES product_edit_suggestions(id) ON DELETE CASCADE not valid;

alter table "public"."product_edit_suggestion_subcategories" validate constraint "product_edit_suggestion_subcate_product_edit_suggestion_id_fkey";

alter table "public"."product_edit_suggestion_subcategories" add constraint "product_edit_suggestion_subcategories_subcategory_id_fkey" FOREIGN KEY (subcategory_id) REFERENCES subcategories(id) ON DELETE CASCADE not valid;

alter table "public"."product_edit_suggestion_subcategories" validate constraint "product_edit_suggestion_subcategories_subcategory_id_fkey";

alter table "public"."product_edit_suggestions" add constraint "product_edit_suggestions_category_id_fkey" FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE not valid;

alter table "public"."product_edit_suggestions" validate constraint "product_edit_suggestions_category_id_fkey";

alter table "public"."product_edit_suggestions" add constraint "product_edit_suggestions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."product_edit_suggestions" validate constraint "product_edit_suggestions_created_by_fkey";

alter table "public"."product_edit_suggestions" add constraint "product_edit_suggestions_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."product_edit_suggestions" validate constraint "product_edit_suggestions_product_id_fkey";

alter table "public"."product_edit_suggestions" add constraint "product_edit_suggestions_sub_brand_id_fkey" FOREIGN KEY (sub_brand_id) REFERENCES sub_brands(id) ON DELETE CASCADE not valid;

alter table "public"."product_edit_suggestions" validate constraint "product_edit_suggestions_sub_brand_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_product_edit_suggestion(p_product_id bigint, p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_sub_brand_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF products
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
       delete_subcategories as (select subcategory_id
                                from current_subcategories o
                                       left join subcategories_for_product n on n.subcategory_id = o.subcategory_id
                                where n is null),
       add_subcategories as (select subcategory_id
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



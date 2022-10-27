CREATE SEQUENCE "public"."brand_edit_suggestions_id_seq";

CREATE SEQUENCE "public"."company_edit_suggestions_id_seq";

CREATE SEQUENCE "public"."sub_brand_edit_suggestion_id_seq";

CREATE TABLE "public"."brand_edit_suggestions" (
  "id" bigint NOT NULL DEFAULT nextval('brand_edit_suggestions_id_seq'::regclass),
  "brand_id" bigint NOT NULL,
  "name" text,
  "brand_owner_id" bigint,
  "created_by" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE "public"."company_edit_suggestions" (
  "id" bigint NOT NULL DEFAULT nextval('company_edit_suggestions_id_seq'::regclass),
  "company_id" bigint NOT NULL,
  "name" text,
  "logo_url" text,
  "created_by" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE "public"."sub_brand_edit_suggestion" (
  "id" bigint NOT NULL DEFAULT nextval('sub_brand_edit_suggestion_id_seq'::regclass),
  "sub_brand_id" bigint NOT NULL,
  "name" text,
  "brand_id" bigint,
  "created_by" uuid NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

ALTER SEQUENCE "public"."brand_edit_suggestions_id_seq" owned BY "public"."brand_edit_suggestions"."id";

ALTER SEQUENCE "public"."company_edit_suggestions_id_seq" owned BY "public"."company_edit_suggestions"."id";

ALTER SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" owned BY "public"."sub_brand_edit_suggestion"."id";

CREATE UNIQUE INDEX brand_edit_suggestions_pkey ON public.brand_edit_suggestions USING btree (id);

CREATE UNIQUE INDEX company_edit_suggestions_pkey ON public.company_edit_suggestions USING btree (id);

CREATE UNIQUE INDEX sub_brand_edit_suggestion_pkey ON public.sub_brand_edit_suggestion USING btree (id);

ALTER TABLE "public"."brand_edit_suggestions"
  ADD CONSTRAINT "brand_edit_suggestions_pkey" PRIMARY KEY USING INDEX "brand_edit_suggestions_pkey";

ALTER TABLE "public"."company_edit_suggestions"
  ADD CONSTRAINT "company_edit_suggestions_pkey" PRIMARY KEY USING INDEX "company_edit_suggestions_pkey";

ALTER TABLE "public"."sub_brand_edit_suggestion"
  ADD CONSTRAINT "sub_brand_edit_suggestion_pkey" PRIMARY KEY USING INDEX "sub_brand_edit_suggestion_pkey";

ALTER TABLE "public"."brand_edit_suggestions"
  ADD CONSTRAINT "brand_edit_suggestions_brand_id_fkey" FOREIGN KEY (brand_id) REFERENCES brands (id) ON DELETE CASCADE NOT valid;

ALTER TABLE "public"."brand_edit_suggestions" validate CONSTRAINT "brand_edit_suggestions_brand_id_fkey";

ALTER TABLE "public"."brand_edit_suggestions"
  ADD CONSTRAINT "brand_edit_suggestions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles (id) ON DELETE CASCADE NOT valid;

ALTER TABLE "public"."brand_edit_suggestions" validate CONSTRAINT "brand_edit_suggestions_created_by_fkey";

ALTER TABLE "public"."company_edit_suggestions"
  ADD CONSTRAINT "company_edit_suggestions_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE NOT valid;

ALTER TABLE "public"."company_edit_suggestions" validate CONSTRAINT "company_edit_suggestions_company_id_fkey";

ALTER TABLE "public"."company_edit_suggestions"
  ADD CONSTRAINT "company_edit_suggestions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles (id) ON DELETE CASCADE NOT valid;

ALTER TABLE "public"."company_edit_suggestions" validate CONSTRAINT "company_edit_suggestions_created_by_fkey";

ALTER TABLE "public"."sub_brand_edit_suggestion"
  ADD CONSTRAINT "sub_brand_edit_suggestion_brand_id_fkey" FOREIGN KEY (brand_id) REFERENCES brands (id) ON DELETE CASCADE NOT valid;

ALTER TABLE "public"."sub_brand_edit_suggestion" validate CONSTRAINT "sub_brand_edit_suggestion_brand_id_fkey";

ALTER TABLE "public"."sub_brand_edit_suggestion"
  ADD CONSTRAINT "sub_brand_edit_suggestion_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles (id) ON DELETE CASCADE NOT valid;

ALTER TABLE "public"."sub_brand_edit_suggestion" validate CONSTRAINT "sub_brand_edit_suggestion_created_by_fkey";

ALTER TABLE "public"."sub_brand_edit_suggestion"
  ADD CONSTRAINT "sub_brand_edit_suggestion_sub_brand_id_fkey" FOREIGN KEY (sub_brand_id) REFERENCES sub_brands (id) ON DELETE CASCADE NOT valid;

ALTER TABLE "public"."sub_brand_edit_suggestion" validate CONSTRAINT "sub_brand_edit_suggestion_sub_brand_id_fkey";

SET check_function_bodies = OFF;

DROP FUNCTION IF EXISTS public.fnc__create_company_edit_suggestion;

CREATE OR REPLACE FUNCTION public.fnc__create_company_edit_suggestion (p_company_id bigint, p_name text, p_logo_url text)
  RETURNS SETOF company_edit_suggestions
  LANGUAGE plpgsql
  AS $function$
DECLARE
  v_company_edit_suggestion_id bigint;
  v_changed_name text;
  v_changed_logo_url text;
  v_current_company companies%ROWTYPE;
BEGIN
  SELECT
    *
  FROM
    companies
  WHERE
    id = p_company_id INTO v_current_company;
  IF v_current_company.name != p_name THEN
    v_changed_name = p_name;
  END IF;
  IF v_current_company.name != p_logo_url THEN
    v_changed_logo_url = p_logo_url;
  END IF;
  INSERT INTO company_edit_suggestions (company_id, name, logo_url, created_by)
    VALUES (p_company_id, v_changed_name, v_changed_logo_url, auth.uid ())
  RETURNING
    id INTO v_company_edit_suggestion_id;
  RETURN query (
    SELECT
      *
    FROM company_edit_suggestions
    WHERE
      id = v_company_edit_suggestion_id);
END
$function$;

DROP FUNCTION IF EXISTS public.fnc__create_product_edit_suggestion;

CREATE OR REPLACE FUNCTION public.fnc__create_product_edit_suggestion (p_product_id bigint, p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_sub_brand_id bigint DEFAULT NULL::bigint)
  RETURNS SETOF product_edit_suggestions
  LANGUAGE plpgsql
  AS $function$
DECLARE
  v_product_edit_suggestion_id bigint;
  v_changed_name text;
  v_changed_description text;
  v_changed_category_id bigint;
  v_changed_sub_brand_id bigint;
  v_current_product products%ROWTYPE;
BEGIN
  SELECT
    *
  FROM
    products
  WHERE
    id = p_product_id INTO v_current_product;
  IF v_current_product.name != p_name THEN
    v_changed_name = p_name;
  END IF;
  IF v_current_product.name != p_description THEN
    v_changed_description = p_description;
  END IF;
  IF v_current_product.description != p_description THEN
    v_changed_description = p_description;
  END IF;
  IF v_current_product.category_id != p_category_id THEN
    v_changed_category_id = p_category_id;
  END IF;
  IF v_current_product.sub_brand_id != p_sub_brand_id THEN
    v_changed_sub_brand_id = p_sub_brand_id;
  END IF;
  INSERT INTO product_edit_suggestions (product_id, name, description, category_id, sub_brand_id, created_by)
    VALUES (p_product_id, v_changed_name, v_changed_description, v_changed_category_id, v_changed_sub_brand_id, auth.uid ())
  RETURNING
    id INTO v_product_edit_suggestion_id;
  WITH subcategories_for_product AS (
    SELECT
      v_product_edit_suggestion_id product_edit_suggestion_id,
      unnest(p_sub_category_ids) subcategory_id
),
current_subcategories AS (
  SELECT
    subcategory_id
  FROM
    products_subcategories
  WHERE
    product_id = p_product_id
),
delete_subcategories AS (
  SELECT
    o.subcategory_id
  FROM
    current_subcategories o
    LEFT JOIN subcategories_for_product n ON n.subcategory_id = o.subcategory_id
  WHERE
    n IS NULL
),
add_subcategories AS (
  SELECT
    n.subcategory_id
  FROM
    subcategories_for_product n
    LEFT JOIN current_subcategories o ON o.subcategory_id IS NULL
  WHERE
    o.subcategory_id IS NULL
),
combined AS (
  SELECT
    subcategory_id,
    TRUE DELETE FROM delete_subcategories
  UNION ALL
  SELECT
    subcategory_id,
    FALSE
  FROM
    add_subcategories)
  INSERT INTO product_edit_suggestion_subcategories (product_edit_suggestion_id, subcategory_id, DELETE
)
SELECT
  v_product_edit_suggestion_id product_edit_suggestion_id,
  subcategory_id,
  DELETE FROM combined;
  RETURN query (
    SELECT
      *
    FROM product_edit_suggestions
    WHERE
      id = v_product_edit_suggestion_id);
END
$function$;


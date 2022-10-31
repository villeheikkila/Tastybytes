DROP TRIGGER IF EXISTS "check_verification" ON "public"."check_ins";

DROP POLICY "Enable update for admin" ON "public"."brands";

ALTER TABLE "public"."brand_edit_suggestions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."brands"
  ADD COLUMN "logo_url" text;

DROP VIEW csv_export CASCADE;

ALTER TABLE "public"."check_ins"
  ALTER COLUMN "rating" SET data TYPE rating USING "rating"::rating;

ALTER TABLE "public"."company_edit_suggestions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."product_edit_suggestion_subcategories" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."product_edit_suggestions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."sub_brand_edit_suggestion" ENABLE ROW LEVEL SECURITY;

SET check_function_bodies = OFF;

CREATE OR REPLACE FUNCTION public.tg__forbid_changing_check_in_id ()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'public'
  AS $function$
BEGIN
  NEW.check_in_id = OLD.check_in_id;
END;
$function$;

CREATE OR REPLACE VIEW "public"."csv_export" AS
WITH agg_products AS (
  SELECT
    cat.name AS category,
    string_agg(sc.name, ', '::text ORDER BY sc.name) AS subcategory,
    bo.name AS brand_owner,
    b.name AS brand,
    s.name AS sub_brand,
    p.name,
    p.id
  FROM ((((((products p
            LEFT JOIN sub_brands s ON ((p.sub_brand_id = s.id)))
          LEFT JOIN brands b ON ((s.brand_id = b.id)))
        LEFT JOIN companies bo ON ((b.brand_owner_id = bo.id)))
      LEFT JOIN categories cat ON ((p.category_id = cat.id)))
    LEFT JOIN products_subcategories ps ON ((ps.product_id = p.id)))
    LEFT JOIN subcategories sc ON ((ps.subcategory_id = sc.id)))
GROUP BY
  cat.name,
  bo.name,
  b.name,
  p.name,
  s.name,
  p.description,
  p.id
)
SELECT
  pr.id,
  ap.category,
  ap.subcategory,
  m.name AS manufacturer,
  ap.brand_owner,
  ap.brand,
  ap.sub_brand,
  ap.name,
  string_agg(c.review, ', '::text) AS reviews,
  string_agg((((c.rating)::double precision / (2)::double precision))::text, ', '::text) AS ratings,
  pr.username
FROM ((((check_ins c
      LEFT JOIN agg_products ap ON ((ap.id = c.product_id)))
    LEFT JOIN product_variants pv ON ((pv.id = c.product_variant_id)))
  LEFT JOIN companies m ON ((pv.manufacturer_id = m.id)))
  LEFT JOIN profiles pr ON ((c.created_by = pr.id)))
GROUP BY
  pr.id,
  pr.username,
  ap.category,
  ap.subcategory,
  m.name,
  ap.brand_owner,
  ap.brand,
  ap.sub_brand,
  ap.name,
  ap.id;

CREATE FUNCTION fnc__export_data ()
  RETURNS SETOF csv_export
  LANGUAGE plpgsql
  AS $$
BEGIN
  RETURN query (
    SELECT
      *
    FROM csv_export
    WHERE
      id = auth.uid ());
END;
$$;

CREATE OR REPLACE FUNCTION public.tg__friend_request_check ()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'public'
  AS $function$
BEGIN
  -- make sure that the sender is the current user and that the profiles can't be updated later
  NEW.user_id_1 = (
    CASE WHEN TG_OP = 'INSERT' THEN
      auth.uid ()
    ELSE
      OLD.user_id_1
    END);
  NEW.user_id_2 = (
    CASE WHEN TG_OP = 'INSERT' THEN
      NEW.user_id_2
    ELSE
      OLD.user_id_2
    END);
  RETURN new;
END;
$function$;

CREATE OR REPLACE FUNCTION public.tg__is_verified_check ()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'public'
  AS $function$
BEGIN
  IF fnc__has_permission (auth.uid (), 'can_verify') IS FALSE THEN
    NEW.is_verified = (
      CASE WHEN TG_OP = 'INSERT' THEN
        FALSE
      ELSE
        OLD.is_verified
      END);
  ELSE
    -- Everything created by an user that can verify is created as verified
    NEW.is_verified = (
      CASE WHEN TG_OP = 'INSERT' THEN
        TRUE
      ELSE
        (
          CASE WHEN NEW.is_verified IS NULL THEN
            OLD.is_verified
          ELSE
            NEW.is_verified
          END)
      END);
  END IF;
  RETURN new;
END;
$function$;

CREATE OR REPLACE FUNCTION public.tg__must_be_friends ()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'public'
  AS $function$
DECLARE
  v_friend_id bigint;
BEGIN
  SELECT
    id
  FROM
    friends
  WHERE (user_id_1 = auth.uid ()
    AND user_id_2 = NEW.profile_id)
    OR (user_id_1 = NEW.profile_id
      AND user_id_2 = auth.uid ()) INTO v_friend_id;
  IF v_friend_id IS NULL THEN
    RAISE EXCEPTION 'included profile must be a friend'
      USING errcode = 'not_in_friends';
    ELSE
      RETURN new;
    END IF;
END;
$function$;

CREATE POLICY "Allow deleting for users with permission" ON "public"."brand_edit_suggestions" AS permissive
  FOR DELETE TO authenticated
    USING (fnc__has_permission (auth.uid (), 'can_delete_suggestions'::text));

CREATE POLICY "Enable delete for creator" ON "public"."brand_edit_suggestions" AS permissive
  FOR DELETE TO public
    USING ((auth.uid () = created_by));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."brand_edit_suggestions" AS permissive
  FOR INSERT TO authenticated
    WITH CHECK (TRUE);

CREATE POLICY "Allow deleting for users with permission" ON "public"."company_edit_suggestions" AS permissive
  FOR DELETE TO authenticated
    USING (fnc__has_permission (auth.uid (), 'can_delete_suggestions'::text));

CREATE POLICY "Enable delete for creator" ON "public"."company_edit_suggestions" AS permissive
  FOR DELETE TO public
    USING ((auth.uid () = created_by));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."company_edit_suggestions" AS permissive
  FOR INSERT TO authenticated
    WITH CHECK (TRUE);

CREATE POLICY "Allow deleting for users with permission" ON "public"."product_edit_suggestion_subcategories" AS permissive
  FOR DELETE TO authenticated
    USING (fnc__has_permission (auth.uid (), 'can_delete_suggestions'::text));

CREATE POLICY "Enable delete for creator" ON "public"."product_edit_suggestion_subcategories" AS permissive
  FOR DELETE TO public
    USING ((EXISTS (
      SELECT
        1
      FROM (product_edit_suggestion_subcategories pess
    LEFT JOIN product_edit_suggestions pes ON ((pess.product_edit_suggestion_id = pes.id)))
  WHERE (pes.created_by = auth.uid ()))));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_edit_suggestion_subcategories" AS permissive
  FOR INSERT TO authenticated
    WITH CHECK (TRUE);

CREATE POLICY "Allow deleting for users with permission" ON "public"."product_edit_suggestions" AS permissive
  FOR DELETE TO authenticated
    USING (fnc__has_permission (auth.uid (), 'can_delete_suggestions'::text));

CREATE POLICY "Enable delete for creator" ON "public"."product_edit_suggestions" AS permissive
  FOR DELETE TO public
    USING ((auth.uid () = created_by));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_edit_suggestions" AS permissive
  FOR INSERT TO authenticated
    WITH CHECK (TRUE);

CREATE POLICY "Allow deleting for users with permission" ON "public"."sub_brand_edit_suggestion" AS permissive
  FOR DELETE TO authenticated
    USING (fnc__has_permission (auth.uid (), 'can_delete_suggestions'::text));

CREATE POLICY "Enable delete for creator" ON "public"."sub_brand_edit_suggestion" AS permissive
  FOR DELETE TO public
    USING ((auth.uid () = created_by));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."sub_brand_edit_suggestion" AS permissive
  FOR INSERT TO authenticated
    WITH CHECK (TRUE);

CREATE TRIGGER forbid_moving_comment_to_different_check_in
  BEFORE UPDATE ON public.check_in_comments
  FOR EACH ROW
  EXECUTE FUNCTION tg__forbid_changing_check_in_id ();


ALTER TABLE "public"."check_ins"
    ADD COLUMN "location_id" uuid;

ALTER TABLE "public"."locations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."check_ins"
    ADD CONSTRAINT "check_ins_location_id_fkey" FOREIGN KEY (location_id) REFERENCES locations (id) ON DELETE SET NULL NOT valid;

ALTER TABLE "public"."check_ins" validate CONSTRAINT "check_ins_location_id_fkey";

CREATE POLICY "Enable insert for authenticated users only" ON "public"."locations" AS permissive
    FOR INSERT TO authenticated
        WITH CHECK (TRUE);

CREATE POLICY "Enable read access for all users" ON "public"."locations" AS permissive
    FOR SELECT TO public
        USING (TRUE);

CREATE TRIGGER stamp_created_by
    BEFORE INSERT OR UPDATE ON public.locations
    FOR EACH ROW
    EXECUTE FUNCTION tg__stamp_created_at ();


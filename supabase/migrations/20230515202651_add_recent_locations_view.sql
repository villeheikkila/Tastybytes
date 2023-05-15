set check_function_bodies = off;

create or replace view "public"."view__recent_locations_from_current_user" as  SELECT DISTINCT ON (l.id) l.id,
    l.country_code,
    l.name,
    l.title,
    l.longitude,
    l.latitude,
    l.created_by,
    l.created_at
   FROM ((profiles p
     JOIN check_ins c ON ((p.id = c.created_by)))
     JOIN locations l ON ((c.location_id = l.id)))
  WHERE (p.id = auth.uid())
  ORDER BY l.id, c.check_in_at DESC;


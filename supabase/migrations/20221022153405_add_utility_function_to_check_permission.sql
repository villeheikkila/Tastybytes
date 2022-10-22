set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__has_permission(p_uid uuid, p_permission_name text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
select exists(select 1
              from (((permissions p
                left join roles_permissions rp on ((rp.permission_id = p.id)))
                left join roles r on ((rp.role_id = r.id)))
                left join profiles_roles pr on ((r.id = pr.role_id)))
              where ((pr.profile_id = p_uid) and (p.name = p_permission_name)))
$function$
;

create policy "Enable delete for users with can_delete_products permission"
on "public"."products_subcategories"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT 1
   FROM (((permissions p
     LEFT JOIN roles_permissions rp ON ((rp.permission_id = p.id)))
     LEFT JOIN roles r ON ((rp.role_id = r.id)))
     LEFT JOIN profiles_roles pr ON ((r.id = pr.role_id)))
  WHERE ((pr.profile_id = auth.uid()) AND (p.name = 'can_delete_products'::text)))));




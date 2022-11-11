alter table "public"."secrets" drop column "supabase_url";

alter table "public"."secrets" add column "project_id" text not null;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_edge_function_authorization_header()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
select concat('{ "Authorization": "Bearer ', supabase_anon_key, '" }')::jsonb from secrets limit 1;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__get_edge_function_url(p_function_name text)
 RETURNS text
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
select concat('https://', project_id, '.functions.supabase.co', '/', p_function_name) from secrets limit 1;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__refresh_firebase_access_token()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
  v_url text;
  v_headers jsonb;
begin
  select fnc__get_edge_function_url('get-fcm-access-token') into v_url;
  select fnc__get_edge_function_authorization_header() into v_headers;
  perform net.http_get(v_url, headers := v_headers);
  end;
$function$
;

SELECT cron.schedule('*/30 * * * *', 'select * from fnc__refresh_firebase_access_token()');

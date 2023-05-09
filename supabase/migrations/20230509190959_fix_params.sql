alter table "auth"."flow_state" drop constraint "flow_state_pkey";

drop index if exists "auth"."flow_state_pkey";

drop index if exists "auth"."idx_auth_code";

drop index if exists "auth"."idx_user_id_auth_method";

drop table "auth"."flow_state";

drop type "auth"."code_challenge_method";

CREATE INDEX refresh_tokens_token_idx ON auth.refresh_tokens USING btree (token);


drop function if exists "public"."fnc__merge_locations"(p_location_id bigint, p_to_location_id bigint);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__merge_locations(p_location_id uuid, p_to_location_id uuid)
 RETURNS SETOF products
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__current_user_has_permission('can_merge_locations') then
    alter table locations
      disable trigger check_verification;

    update check_ins set location_id = p_to_location_id where location_id = purchase_location_id;
    delete from locations where id = p_location_id;

    alter table locations
      enable trigger check_verification;
  end if;
end;
$function$
;



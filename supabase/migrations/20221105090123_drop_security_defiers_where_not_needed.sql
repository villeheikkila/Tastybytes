set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__search_products(p_search_term text)
 RETURNS SETOF products
 LANGUAGE sql
AS $function$
select p.*
from products p
         left join "sub_brands" sb on sb.id = p."sub_brand_id"
         left join brands b on sb.brand_id = b.id
         left join companies c on b.brand_owner_id = c.id
WHERE p.name ilike p_search_term
   or p.description ilike p_search_term
   or sb.name ilike p_search_term
   or b.name ilike p_search_term
   or c.name ilike p_search_term;
$function$
;

revoke execute on function fnc__accept_friend_request from anon;
revoke execute on function fnc__create_check_in from anon;
revoke execute on function fnc__create_company_edit_suggestion from anon;
revoke execute on function fnc__create_product from anon;
revoke execute on function fnc__create_product_edit_suggestion from anon;
revoke execute on function fnc__current_user_has_permission from anon;
revoke execute on function fnc__delete_current_user from anon;
revoke execute on function fnc__export_data from anon;
revoke execute on function fnc__get_activity_feed from anon;
revoke execute on function fnc__get_company_summary from anon;
revoke execute on function fnc__get_product_summary from anon;
revoke execute on function fnc__get_profile_summary from anon;
revoke execute on function fnc__has_permission from anon;
revoke execute on function fnc__merge_products from anon;
revoke execute on function fnc__search_products from anon;
revoke execute on function fnc__update_check_in from anon;
revoke execute on function fnc__search_products from anon;
revoke execute on function fnc__search_products from anon;
revoke execute on function tg__check_friend_status_transition from anon;
revoke execute on function tg__check_subcategory_constraint from anon;
revoke execute on function tg__create_default_sub_brand from anon;
revoke execute on function tg__create_friend_request from anon;
revoke execute on function tg__create_profile_for_new_user from anon;
revoke execute on function tg__create_profile_settings from anon;
revoke execute on function tg__forbid_changing_check_in_id from anon;
revoke execute on function tg__forbid_send_messages_too_often from anon;
revoke execute on function tg__friend_request_check from anon;
revoke execute on function tg__is_verified_check from anon;
revoke execute on function tg__make_id_immutable from anon;
revoke execute on function tg__must_be_friends from anon;
revoke execute on function tg__send_check_in_reaction_notification from anon;
revoke execute on function tg__send_friend_request_notification from anon;
revoke execute on function tg__send_tagged_in_check_in_notification from anon;
revoke execute on function tg__set_avatar_on_upload from anon;
revoke execute on function tg__stamp_created_at from anon;
revoke execute on function tg__stamp_created_by from anon;

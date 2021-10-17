--! Previous: sha1:2ad72da6bac707312658463645a04237c3c7ca5f
--! Hash: sha1:75a22705ed605efe9977682348d29a05a6849aa9

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE VIEW app_public.public_users AS
WITH public_users AS (
  SELECT
    u.*
  FROM
    app_public.users u
    LEFT JOIN app_public.user_settings s ON u.id = s.id
  WHERE
    s.is_public = TRUE
)
SELECT
  p.*,
  CASE WHEN app_public.friends.user_id_1 IS NULL THEN
    FALSE
  ELSE
    TRUE
  END AS is_friend,
  CASE WHEN sfr.sender_id IS NULL THEN
    FALSE
  ELSE
    TRUE
  END AS is_pending_sent_friend_request,
  CASE WHEN rfr.sender_id IS NULL THEN
    FALSE
  ELSE
    TRUE
  END AS is_pending_friend_request
FROM
  public_users p
  LEFT JOIN app_public.friends ON app_public.friends.user_id_1 = current_user_id ()
    AND p.id = app_public.friends.user_id_2
  LEFT JOIN app_public.friend_requests sfr ON sfr.sender_id = current_user_id ()
    AND sfr.receiver_id = p.id
  LEFT JOIN app_public.friend_requests rfr ON rfr.sender_id = p.id
    AND rfr.receiver_id = current_user_id ()
WHERE
  p.id != current_user_id ();

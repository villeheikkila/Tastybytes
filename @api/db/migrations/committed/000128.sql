--! Previous: sha1:778dedc742cfab2b152900717ed43ec8145fb64c
--! Hash: sha1:85d1c40f2ecfc10c5b2a7a872b33256a2d97e3cf

--! split: 1-current.sql
-- Enter migration here
DROP VIEW app_public.public_users;

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
  CASE WHEN f.user_id_1 IS NOT NULL THEN
    'friend'::app_public.friend_status
  WHEN sfr.sender_id IS NOT NULL THEN
    'pending-sent'::app_public.friend_status
  WHEN rfr.sender_id IS NULL THEN
    'pending-received'::app_public.friend_status
  ELSE
    'none'::app_public.friend_status
  END AS friend_status
FROM
  public_users p
  LEFT JOIN app_public.friends f ON f.user_id_1 = current_user_id ()
    AND p.id = f.user_id_2
  LEFT JOIN app_public.friend_requests sfr ON sfr.sender_id = current_user_id ()
    AND sfr.receiver_id = p.id
  LEFT JOIN app_public.friend_requests rfr ON rfr.sender_id = p.id
    AND rfr.receiver_id = current_user_id ()
WHERE
  p.id != current_user_id ();

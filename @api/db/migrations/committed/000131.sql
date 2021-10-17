--! Previous: sha1:a2f8b4ca16f20bd08f580bdbf01bc73423d49f78
--! Hash: sha1:a4b15f20e52d69e36ae28a4ee7a8627aa4e76ba2

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

GRANT SELECT ON TABLE app_public.public_users TO tasted_visitor;

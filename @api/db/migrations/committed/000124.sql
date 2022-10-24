--! Previous: sha1:dd7338136e73a9960c341a23c242d008cea2a64f
--! Hash: sha1:2ad72da6bac707312658463645a04237c3c7ca5f

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
  END AS is_friend
FROM
  public_users p
  LEFT JOIN app_public.friends ON app_public.friends.user_id_1 = current_user_id ()
    AND p.id = app_public.friends.user_id_2
WHERE
  p.id != current_user_id ();

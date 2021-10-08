--! Previous: sha1:8a54376e451cdcc2bcf552d622393d4af787891e
--! Hash: sha1:52877332394a5702df2f1673f17916e74b3b1178

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE VIEW app_public.public_users AS
SELECT
  app_public.users.*,
  CASE WHEN app_public.friends.user_id_1 IS NULL THEN
    FALSE
  ELSE
    TRUE
  END AS is_friend
FROM
  app_public.users
  LEFT JOIN app_public.user_settings ON app_public.users.id = app_public.user_settings.id
  LEFT JOIN app_public.friends ON app_public.friends.user_id_1 = current_user_id ()
    AND app_public.friends.user_id_2 != current_user_id ()
WHERE
  app_public.user_settings.is_public = TRUE;

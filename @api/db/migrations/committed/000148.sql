--! Previous: sha1:0fc037a01c47639c4ae2df587ff6f9d166916025
--! Hash: sha1:35a6887a334bf1bb96b5a265a168feb1f9afdba8

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE VIEW app_public.public_users AS
WITH public_users AS (
  SELECT u.*
  FROM app_public.users u
         LEFT JOIN app_public.user_settings s ON u.id = s.id
  WHERE s.is_public = TRUE
)
SELECT p.*,
       f.status
FROM public_users p
       LEFT JOIN app_public.friends f ON (f.user_id_1 = current_user_id()
  AND p.id = f.user_id_2) OR (f.user_id_1 = p.id AND f.user_id_1 = current_user_id())
WHERE p.id != current_user_id();

create or replace view app_public.activity_feed as
select app_public.check_ins.*
from app_public.check_ins
       left join
     app_public.friends on
           app_public.check_ins.author_id = app_public.friends.user_id_2 or
           app_public.check_ins.author_id = app_public.friends.user_id_1
order by app_public.check_ins.created_at;

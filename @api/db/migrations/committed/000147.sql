--! Previous: sha1:72853f756a10a54a9168fa1e59ca65d8884c1be7
--! Hash: sha1:0fc037a01c47639c4ae2df587ff6f9d166916025

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."friends"("user_id_2");
CREATE INDEX ON "app_public"."friends"("user_id_1");

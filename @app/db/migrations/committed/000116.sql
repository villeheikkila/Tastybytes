--! Previous: sha1:31f4bb8f8bea023c6bea4fa8701d5676d19cd37e
--! Hash: sha1:fbdc44524d2ede4dd690ce2f8138571a5f367a5d

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."friends"("user_id_2");
CREATE INDEX ON "app_public"."check_in_likes"("liked_by");

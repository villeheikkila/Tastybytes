--! Previous: sha1:b02346477c8199e9799b67802d3d72123ff0b1db
--! Hash: sha1:a9df49923a664bd1f074df2fa3984d36c84c60e5

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."check_in_comments"("check_in_id");

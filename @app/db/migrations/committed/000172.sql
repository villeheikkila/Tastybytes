--! Previous: sha1:0e13281693c6c409a65c8f3ef57642973bbf9100
--! Hash: sha1:4e905676f02ebb153b17a4de99887c68c8a56985

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."check_in_friends"("check_in_id")

--! Previous: sha1:ce71a7f1c73d4e0f0278ff76ea89d707497b2da6
--! Hash: sha1:e9f59706c9c65db599d192ad297949d1669e9563

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."check_in_friends"("friend_id");

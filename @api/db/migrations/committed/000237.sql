--! Previous: sha1:a1e8d9f9f4ce7090b7c95b1d7ca677db68e9c6ac
--! Hash: sha1:8e8e63c8c826619fad7a53e1c9269506579e0cc9

--! split: 1-current.sql
-- enter migration here
create index on "app_public"."friends" ("blocked_by");

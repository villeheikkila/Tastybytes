--! Previous: sha1:ba0826be6d765de3f248db21a2552d4e23ffa866
--! Hash: sha1:55acd3388c1c1c091bb14692ed872a46ebed2920

--! split: 1-current.sql
-- Enter migration here
GRANT SELECT ON TABLE activity_feed TO tasted_visitor;

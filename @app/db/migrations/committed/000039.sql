--! Previous: sha1:61c96d21211bbc6785e512176a198d849a53be13
--! Hash: sha1:8a1ba6b8cd48bac77faa2dd48e1b2617f7227e7a

--! split: 1-current.sql
-- Enter migration here
GRANT UPDATE(first_name) ON TABLE app_public.users TO tasted_visitor;
GRANT UPDATE(last_name) ON TABLE app_public.users TO tasted_visitor;

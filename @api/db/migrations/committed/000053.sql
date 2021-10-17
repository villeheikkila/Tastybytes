--! Previous: sha1:5f796dd508cafd75a1dcd8240449be460fe7f7dc
--! Hash: sha1:b3d48c04e1962d2d6ecb7d16ea287a28a614fcdc

--! split: 1-current.sql
-- Enter migration here
GRANT SELECT ON TABLE app_public.user_settings TO tasted_visitor;

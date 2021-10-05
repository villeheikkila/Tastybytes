--! Previous: sha1:b3d48c04e1962d2d6ecb7d16ea287a28a614fcdc
--! Hash: sha1:a7b9dc63ce80950fba4a073843c5d83bf646493a

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.user_settings alter is_public_check_ins
set default true;

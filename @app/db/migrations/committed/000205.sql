--! Previous: sha1:60e8ccbf3f72621c41f4e005ad46f3b9f64d4269
--! Hash: sha1:2117bb6774d852de75aa3ee367bddb73c10719e1

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.types ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.tags ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.locations ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.items ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.item_edit_suggestions ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.friends ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.companies ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.check_in_tags ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.check_in_likes ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.check_in_friends ENABLE ROW LEVEL SECURITY;

ALTER TABLE app_public.check_in_comments ENABLE ROW LEVEL SECURITY;

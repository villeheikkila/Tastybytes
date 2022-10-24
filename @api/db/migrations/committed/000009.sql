--! Previous: sha1:0097f4ed308bab2a82b6e6edaa48938dfbd89597
--! Hash: sha1:fa024d356893d36f95a3d798eccd30e11a1e3a32

--! split: 1-current.sql
-- Enter migration here
grant select on app_public.companies to :DATABASE_VISITOR;
grant select on app_public.categories to :DATABASE_VISITOR;
grant select on app_public.types to :DATABASE_VISITOR;
grant select on app_public.items to :DATABASE_VISITOR;
grant select on app_public.check_ins to :DATABASE_VISITOR;
grant select on app_public.locations to :DATABASE_VISITOR;
grant select on app_public.items_tags to :DATABASE_VISITOR;

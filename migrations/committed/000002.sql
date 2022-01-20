--! Previous: sha1:b8c42a0fd65cfeae713e1ee8e471417a7cfdf70b
--! Hash: sha1:4b7cf5158928c941a82c10cf88da9de8b9ab0400

-- Enter migration here
revoke all on schema public from public;

alter default privileges revoke all on sequences from public;
alter default privileges revoke all on functions from public;

grant all on schema public to :DATABASE_OWNER;

grant usage on schema public, tasted_public, tasted_hidden to :DATABASE_VISITOR;

alter default privileges in schema public, tasted_public, tasted_hidden
  grant usage, select on sequences to :DATABASE_VISITOR;

alter default privileges in schema public, tasted_public, tasted_hidden
  grant execute on functions to :DATABASE_VISITOR;

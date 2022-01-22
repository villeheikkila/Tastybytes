--! Previous: sha1:fc4e311717cdefacf93a713fa717fe6e2b3da083
--! Hash: sha1:42ed72de2253642c18058d47bcfe82b3618362fd

-- Enter migration here
create table tasted_private.user_secrets (
  user_id uuid not null primary key references tasted_public.users on delete cascade,
  password_hash text
);

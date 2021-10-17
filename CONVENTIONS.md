## Database Roles

- `DATABASE_OWNER` - this is the role that owns the database (**not** the
  database cluster, just the individual database); i.e. it's the role that runs
  all the migrations and owns the resulting schemas, tables and functions.
- `DATABASE_AUTHENTICATOR` - this is the role that PostGraphile connects to the
  database with; it has absolutely minimal permissions (only enough to run the
  introspection queries, and the ability to "switch to" `DATABASE_VISITOR`
  below). When a GraphQL request comes in, we connect to the database as
  `DATABASE_AUTHENTICATOR` and then start a transaction and evaluate the
  equivalent of `SET LOCAL role TO 'DATABASE_VISITOR'`. You might choose to add
  more visitor-like roles (such as an admin role), but the maintainer finds that
  the single role solution tends to be more straightforward and has been
  sufficient for all his needs.
- `DATABASE_VISITOR` - this is the role that the SQL generated from GraphQL
  queries runs as, it's what the vast majority of your `GRANT`s will reference
  and the row level security policies will apply to. It represents both logged
  in AND logged out users to your GraphQL API - it's assumed that your Row Level
  Security policies will deferentiate between these states (and any other
  "application roles" the user may have) to determine what they are permitted to
  do.

The `DATABASE_OWNER` role is also used for certain "elevated privilege"
operations such as login and user registration. Note that `SECURITY DEFINER`
functions adopt the security level of the role that defined the function (as
opposed to `SECURITY INVOKER` which uses the security of the role that is
invoking the function), so you should therefore **make sure to create all
schema, tables, etc. with the `DATABASE_OWNER` in all environments** (local,
dev, production), not with your own user role nor the default superuser role
(often named `postgres`). This ensures that the system behaves as expected when
graduating from your local dev environment to hosted database systems in
production.

### GraphQL naming conventions

1. Operations are named in PascalCase
1. Name the file after the operation or fragment (e.g.
   `fragment EmailsForm_User {...}` would be in a file called
   `EmailsForm_User.graphql`)
1. Do not add `Query`, `Mutation` or `Subscription` suffixes to operations
1. Do not add `Fragment` suffix to fragments
1. Operations (i.e. non-fragments) should never contain an underscore in their
   name - underscores are reserved for fragments.
1. Fragments should always contain exactly one underscore, see fragment naming
   below

### GraphQL fragment naming

Fragments belong to components (or functions) to enable GraphQL composition.
This is one of the most powerful and most important features about doing GraphQL
right - it helps to ensure that you only ask the server for data you actually
need (and allows composing these data requirements between multiple components
for greater efficiency).

Fragments are named according to the following pattern:

```
[ComponentName]_[Distinguisher?][Type]
```

1. `ComponentName` - the name of the React component (or possibly function) that
   owns this fragment.
2. `_` - an underscore
3. `Distinguisher?` - an optional piece of text if this component includes
   multiple fragments that are valid on the same `Type`
4. `Type` - the GraphQL type name upon which this fragment is valid.

For example:

```graphql
fragment EmailsForm_User on User {
  ...
}
```

# Conventions used in this database schema:

## Error code rules

To try and avoid clashes with present or future PostgreSQL error codes, we
require that all custom error codes match the following criteria:

- 5 alphanumeric (capitals) letters
- First character must be a letter
- First character cannot be F, H, P or X.
- Third character cannot be 0 or P.
- Fourth character must be a letter.
- Must not end `000`

Rewritten, the above rules state:

- Char 1: A-Z except F, H, P, X
- Char 2: A-Z0-9
- Char 3: A-Z0-9 except 0, P
- Char 4: A-Z
- Char 5: A-Z0-9

## General

- FFFFF: unknown error
- DNIED: permission denied
- NUNIQ: not unique (from PostgreSQL 23505)
- NTFND: not found
- BADFK: foreign key violation (from PostgreSQL 23503)

## Registration

- MODAT: more data required (e.g. missing email address)

## Authentication

- WEAKP: password is too weak
- LOCKD: too many failed login/password reset attempts; try again in 6 hours
- TAKEN: a different user account is already linked to this profile
- EMTKN: a different user account is already linked to this email
- CREDS: bad credentials (incorrect username/password)
- LOGIN: you're not logged in

## Email management

- VRFY1: you need to verify your email before you can do that
- VRFY2: the target user needs to verify their email before you can do that
- CDLEA: cannot delete last email address (or last verified email address if you
  have verified email addresses)

### Placeholders

We're using placeholders to make this project flexible for new users/projects;
see `.gmrc` (documented in the `graphile-migrate` README) for the full list of
placeholders, but the main one is `:DATABASE_VISITOR` which is the role that
GraphQL users use and is where we grant most of the permissions.

### Naming

- snake_case for tables, functions, columns (avoids having to put them in quotes
  in most cases)
- plural table names (avoids conflicts with e.g. `user` built ins, is better
  depluralized by PostGraphile)
- trigger functions valid for one table only are named
  tg\_[table_name]\_\_[task_name]
- trigger functions valid for many tables are named tg\_\_[task_name]
- trigger names should be prefixed with `_NNN_` where NNN is a three digit
  number that defines the priority of the trigger (use _500_ if unsure)
- prefer lowercase over UPPERCASE, except for the `NEW`, `OLD` and `TG_OP`
  keywords. (This is Benjie's personal preference.)

### Security

- all `security definer` functions should define `set search_path from current`
  due to `CVE-2018-1058`
- `@omit` smart comments should not be used for permissions, instead deferring
  to PostGraphile's RBAC support
- all tables (public or not) should enable RLS
- relevant RLS policy should be defined before granting a permission
- `grant select` should never specify a column list; instead use one-to-one
  relations as permission boundaries
- `grant insert` and `grant update` must ALWAYS specify a column list

### Explicitness

- all functions should explicitly state immutable/stable/volatile
- do not override search_path during migrations or in server code - prefer to
  explicitly list schemas

### Functions

- if a function can be expressed as a single SQL statement it should use the
  `sql` language if possible. Other functions should use `plpgsql`.
- be aware of the function inlining rules:
  https://wiki.postgresql.org/wiki/Inlining_of_SQL_functions

### Relations

- all foreign key `references` statements should have `on delete` clauses. Some
  may also want `on update` clauses, but that's optional
- all comments should be defined using '"escape" string constants' - e.g.
  `E'...'` - because this more easily allows adding special characters such as
  newlines
- defining things (primary key, checks, unique constraints, etc) within the
  `create table` statement is preferable to adding them after

### General conventions (e.g. for PostGraphile compatibility)

- avoid `plv8` and other extensions that aren't built in because they can be
  complex for people to install
- @omit smart comments should be used heavily to remove fields we don't
  currently need in GraphQL - we can always remove them later

### Definitions

Please adhere to the following templates (respecting newlines):

Tables:

```sql
create table <schema_name>.<table_name> (
  ...
);
```

SQL functions:

```sql
create function <fn_name>(<args...>) returns <return_value> as $$
  select ...
  from ...
  inner join ...
  on ...
  where ...
  and ...
  order by ...
  limit ...;
$$ language sql <strict?> <immutable|stable|volatile> <security definer?> set search_path from current;
```

PL/pgSQL functions:

```sql
create function <fn_name>(<args...>) returns <return_value> as $$
declare
  v_[varname] <type>[ = <default>];
  ...
begin
  if ... then
    ...
  end if;
  return <value>;
end;
$$ language plpgsql <strict?> <immutable|stable|volatile> <security definer?> set search_path from current;
```

Triggers:

```sql
create trigger _NNN_trigger_name
  <before|after> <insert|update|delete> on <schema_name>.<table_name>
  for each row [when (<condition>)]
  execute procedure <schema_name.function_name>(...);
```

Comments:

```sql
comment on <table|column|function|...> <fully.qualified.name> is
  E'...';
```

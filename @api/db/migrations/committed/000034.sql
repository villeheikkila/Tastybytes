--! Previous: sha1:6ceb2a9df86b40f5c81398114a3aa8ba64280832
--! Hash: sha1:8571b9abbe4b4a5041d95eb1b78139eb512b071b

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.users
ADD first_name text;
ALTER TABLE app_public.users
ADD CONSTRAINT users_first_name_check CHECK (
    (length(first_name) >= 2)
    AND (length(first_name) <= 56)
  );
ALTER TABLE app_public.users
ADD last_name text;
ALTER TABLE app_public.users
ADD CONSTRAINT users_last_name_check CHECK (
    (length(last_name) >= 2)
    AND (length(last_name) <= 56)
  );
ALTER TABLE app_public.users
ADD location text;
ALTER TABLE app_public.users
ADD CONSTRAINT users_location_check CHECK (
    (length(location) >= 2)
    AND (length(location) <= 56)
  );
ALTER TABLE app_public.users
ADD country text;
ALTER TABLE app_public.users
ADD CONSTRAINT users_country_check CHECK (
    (length(country) >= 2)
    AND (length(country) <= 56)
  );

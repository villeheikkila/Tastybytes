--! Previous: sha1:4e11330076a07762a867f55986b75218c10512ee
--! Hash: sha1:d166506353c1c6654a4b3eb73f17e340524544f0

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE companies DROP CONSTRAINT companies_name_check;
ALTER TABLE companies
ADD CONSTRAINT companies_name_check CHECK (
    (length(name) >= 2)
    AND (length(name) <= 56)
  );

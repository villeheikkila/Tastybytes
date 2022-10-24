--! Previous: sha1:249bedd9a9e1aa2cc50cb4c8063faafce04ddfbe
--! Hash: sha1:770e98b491623e6da570ddeedb7e9053988cc690

--! split: 1-current.sql
-- Enter migration here
create domain short_text as text
  constraint short_text_check check ((length(VALUE) >= 2) AND (length(VALUE) <= 64));

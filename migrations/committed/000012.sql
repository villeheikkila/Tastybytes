--! Previous: sha1:e6b070e64c2075f4df8a9637a2605398b32bb837
--! Hash: sha1:fbcd013860d02a756c8d446cb13e26d075c0529b

-- Enter migration here
create table tasted_public.check_ins (
  id serial primary key,
  rating integer,
  review text,
  product_id integer not null references tasted_public.products(id) on delete cascade,
  author uuid not null references tasted_public.users(id) on delete cascade,
  check_in_date date,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  CONSTRAINT check_ins_review_check CHECK (
    (length(review) >= 1)
    AND (length(review) <= 1024)
  ),
  CONSTRAINT check_ins_rating CHECK (
    rating >= 0
    AND rating <= 10
  )
);

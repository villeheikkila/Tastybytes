DROP TABLE locations;

CREATE TABLE locations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid (),
    country_code char(2) NOT NULL CONSTRAINT locations_countries_fk REFERENCES countries ON DELETE CASCADE,
    name text NOT NULL,
    title text,
    longitude numeric,
    latitude numeric,
    created_by uuid REFERENCES profiles ON DELETE SET NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
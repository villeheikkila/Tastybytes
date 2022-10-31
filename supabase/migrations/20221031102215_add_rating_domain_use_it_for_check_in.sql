CREATE DOMAIN rating AS smallint CHECK (value >= 0
    AND value <= 10);
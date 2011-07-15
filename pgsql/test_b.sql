CREATE OR REPLACE FUNCTION day_in_month(month int, int DEFAULT NULL) RETURNS int AS $$
DECLARE
    year integer;
BEGIN
    IF $2 is NULL THEN
        year := select extract(year from now());
    END IF;        
    return month+year;
END;
$$ LANGUAGE plpgsql;

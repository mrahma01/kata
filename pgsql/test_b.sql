CREATE OR REPLACE FUNCTION day_in_month(month int, int DEFAULT NULL) 
                                                   RETURNS int AS $$
DECLARE
    year integer;
BEGIN
    IF $2 is NULL THEN
        year := 2011;
    END IF;        
    return month+year;
END;
$$ LANGUAGE plpgsql;
--select extract(year from now());
--select to_char(current_date, 'day');
--select current_date + s.a as dates from generate_series(0,14,7) as s(a);

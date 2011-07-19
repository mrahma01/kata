CREATE OR REPLACE FUNCTION day_in_month(month int, int DEFAULT NULL) 
                                                   RETURNS char AS $$
DECLARE
    year integer;
BEGIN
    IF $2 is NULL THEN
        year := 2011;
    END IF;        
    return to_char(to_date('2011-07-18', 'yyyy-mm-dd'), 'Day, dd Month, yyyy');
END;
$$ LANGUAGE plpgsql;
--select extract(year from now());
--select current_date + s.a as dates from generate_series(0,14,7) as s(a);
--select to_char(current_date, 'Day, d Month, yyyy');

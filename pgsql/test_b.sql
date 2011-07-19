CREATE OR REPLACE FUNCTION day_in_month(month int, y int DEFAULT NULL) 
                                                   RETURNS char AS $$
DECLARE
    today varchar;
BEGIN
    IF y is NULL THEN
        today := extract(year from now()) || 
                         '-' || $1 || '-' || 
                          extract(day from now());
    ELSE 
        today := y || '-' || $1 || '-' || extract(day from now());
        RAISE NOTICE '%', today;

    END IF;        
    return to_char(to_date(today, 'yyyy-mm-dd'), 'Day, dd Month, yyyy');
END;
$$ LANGUAGE plpgsql;

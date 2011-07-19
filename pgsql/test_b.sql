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
    return to_char(to_date(today, 'yyyy-mm-dd'), 'Day, dd Month yyyy');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION time_delta_diff(varchar, varchar) RETURNS 
                                                interval AS $$
DECLARE
    a varchar;
    b varchar;
BEGIN
    a := ''''||$2||'''';
    b := ''''||$1||'''';
    RAISE NOTICE '%', a;
    return age(timestamp '2005-02-01 00:20:34' , timestamp '2004-01-02 00:02:34');
END;    
$$ LANGUAGE plpgsql;

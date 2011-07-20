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

CREATE OR REPLACE FUNCTION time_delta_diff(timestamp, timestamp, varchar)                                                         RETURNS int AS $$
DECLARE
    duration interval;
BEGIN
    duration := age($2 , $1);
    IF $3 = 'seconds' THEN
        return EXTRACT('epoch' FROM duration) AS seconds;
    ELSEIF $3 = 'days' THEN
        return floor(EXTRACT('epoch' FROM duration)/86400);
    ELSE
        return duration as default;
    END IF;
END;    
$$ LANGUAGE plpgsql;

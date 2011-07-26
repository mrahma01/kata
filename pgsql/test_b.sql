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
DROP TABLE IF EXISTS tbl1;
CREATE TABLE tbl1 (
    event date
);
insert into tbl1 values('2009-02-01');
insert into tbl1 values('2008-02-01');
insert into tbl1 values('2009-01-03');
insert into tbl1 values('2010-02-01');
insert into tbl1 values('2010-02-01');
insert into tbl1 values('2009-02-11');
insert into tbl1 values('2011-02-01');
insert into tbl1 values('2011-07-17');
insert into tbl1 values('2007-05-03');

CREATE OR REPLACE FUNCTION aggr_date() RETURNS SETOF DATE as $$
DECLARE
    median timestamp;
BEGIN
    RETURN NEXT min(event) from tbl1;
    RETURN NEXT max(event) from tbl1;
    median = max(event) - age(max(event), min(event))/2 from tbl1;
    RETURN NEXT event from tbl1 
                where abs(date_part('day', event - median)) = 
                (select abs(date_part('day', event - median)) 
                as day from tbl1 order by day limit 1);
     
END;
$$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS tbl2;
CREATE TABLE tbl2 (
    event date
);
insert into tbl2 values('2009-02-01');
insert into tbl2 values('2010-12-15');
insert into tbl2 values('2009-01-03');
insert into tbl2 values('2010-02-01');
insert into tbl2 values('2005-02-01');
insert into tbl2 values('2009-02-11');
insert into tbl2 values('2011-07-11');
insert into tbl2 values('2011-07-17');
insert into tbl2 values('2008-05-03');

DROP TYPE IF EXISTS newtbl CASCADE;
CREATE TYPE newtbl AS
   (event_date date,
    occournaces bigint);

CREATE OR REPLACE FUNCTION join_tbls() RETURNS SETOF newtbl AS $$
DECLARE
    row RECORD;
BEGIN
    RETURN query
        select tbl2.event as f1, count(tbl1.event) as f2 from tbl2
        left join tbl1
        on tbl2.event=tbl1.event group by tbl2.event;

    RETURN;
END;
$$ LANGUAGE plpgsql stable;

CREATE OR REPLACE FUNCTION no_match() RETURNS SETOF tbl2 
                                                                   AS $$
BEGIN
    RETURN QUERY 
        select tbl2.event from tbl2 left join tbl1 on tbl2.event=tbl1.event         where tbl1.event is NULL;
    RETURN;
END;
$$ LANGUAGE plpgsql;

DROP TYPE IF EXISTS days CASCADE;
CREATE TYPE days AS
   (days text);

CREATE OR REPLACE FUNCTION day_in_month(month int, y int DEFAULT NULL) 
                                        RETURNS SETOF days AS $$
DECLARE
    today varchar;
    month integer;
BEGIN
    IF y is NULL THEN
        today := extract(year from now()) || 
                         '-' || $1 || '-' || '01';
    ELSE 
        today := y || '-' || $1 || '-' || '01';

    END IF;        
    select into month DATE_PART('days', DATE_TRUNC('month', today::date) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', today::date));
    return query 
        select to_char(today::date + s.a,'Day, dd Month yyyy') as dates from  generate_series(1,(month-1),1) as s(a);
    return;
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
    total integer;
    lower_median date;
    higher_median date;
BEGIN
    total := count(*) from tbl1;
    RETURN NEXT min(event) from tbl1;
    RETURN NEXT max(event) from tbl1;
    if mod(total, 2) = 1 then
        RETURN NEXT event from 
            (select row_number() 
            over (order by event) as row, event
            from tbl1) as tableone
            where row=(select count(*)/2+1 from tbl1);
    else 
        lower_median := event from 
            (select row_number() 
            over (order by event) as row, event
            from tbl1) as tableone
            where row=(select count(*)/2 from tbl1);
        higher_median := event from 
            (select row_number() 
            over (order by event) as row, event
            from tbl1) as tableone
            where row=(select count(*)/2+1 from tbl1);            
        RETURN NEXT lower_median + age(higher_median, lower_median)/2;
    end if;
END;
$$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS tbl2 CASCADE;
CREATE TABLE tbl2 (
    event date
);
insert into tbl2 values('2009-02-01');
insert into tbl2 values('2010-12-15');
insert into tbl2 values('2009-01-03');
insert into tbl2 values('2005-02-01');
insert into tbl2 values('2009-02-11');
insert into tbl2 values('2011-07-11');
insert into tbl2 values('2011-07-17');
insert into tbl2 values('2008-05-03');
insert into tbl2 values('2010-02-22');
insert into tbl2 values('2010-02-10');
insert into tbl2 values('2010-02-08');
insert into tbl2 values('2010-01-25');


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

CREATE OR REPLACE FUNCTION no_match() RETURNS SETOF tbl2 AS $$
BEGIN
    RETURN QUERY 
        select tbl2.event from tbl2 left join tbl1 on tbl2.event=tbl1.event         where tbl1.event is NULL;
    RETURN;
END;
$$ LANGUAGE plpgsql;

DROP TYPE IF EXISTS dates CASCADE;
CREATE TYPE dates AS
   (dates date);

CREATE OR REPLACE FUNCTION missing_days(start_date date, end_date date,
                                day varchar) RETURNS SETOF dates AS $$
DECLARE
    days integer;
BEGIN
    select into days time_delta_diff(start_date, end_date, 'days');
    RETURN query
        select series.date from (select generate_series(0,days) + 
        start_date as date,to_char(generate_series(0,days) + 
        start_date, 'Day') as day_name) as series 
        left join tbl2
        on series.date = tbl2.event
        where tbl2.event is NULL and series.day_name Like $3||'%';
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION perform_check(data date) RETURNS boolean AS $$
BEGIN
    PERFORM * from tbl2 where event=data;
    if not found then
        raise log 'not found';
    end if;
    return found;
END;
$$ LANGUAGE plpgsql stable;


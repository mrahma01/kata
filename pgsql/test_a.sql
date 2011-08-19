DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
    id char(10) primary key CHECK (char_length(id) >= 3),
    fname varchar(30),
    lname varchar(30),
    age integer
);
insert into customer values('111','Argotte', 'Javier', 28);
insert into customer values('222', 'Blair', 'Tony', 17);
insert into customer values('333', 'Obama', 'Barack', 15);
insert into customer values('444', 'Jobs', 'Steve', 11);
insert into customer values('555', 'Gates', 'Bill', 13);


DROP TABLE IF EXISTS genre CASCADE;
CREATE TABLE genre (
    name varchar(50) primary key,
    details varchar(100)
);
insert into genre values('Action');
insert into genre values('Science Fiction');
insert into genre values('Horror');
insert into genre values('Romance');
insert into genre values('Family');

DROP TABLE IF EXISTS pg_rating CASCADE;
CREATE TABLE pg_rating(
    rating varchar(10) primary key,
    suggested_age integer
);
insert into pg_rating values('U', 1);
insert into pg_rating values('PG', 6);
insert into pg_rating values('12', 12);
insert into pg_rating values('12A', 12);
insert into pg_rating values('15', 12);
insert into pg_rating values('18', 18);
insert into pg_rating values('18R', 18);

DROP TABLE IF EXISTS movie CASCADE;
CREATE TABLE movie (
    title varchar(100) PRIMARY KEY,
    genre varchar(50) references genre(name),
    rating varchar(10) references pg_rating(rating)
);
insert into movie values('The Matrix', 'Science Fiction', '12');
insert into movie values('Transformers', 'Science Fiction', '12A');
insert into movie values('Saw', 'Horror', '18');
insert into movie values('My Bloody Valentine', 'Horror', '18');
insert into movie values('Kung Fu Panda', 'Family', 'U');
insert into movie values('Bean the movie', 'Family', 'PG');
insert into movie values('Die Hard', 'Action', '15');
insert into movie values('Rambo', 'Action', '15');
insert into movie values('True Romance', 'Romance', '18');
insert into movie values('Notebook', 'Romance', '12A');
insert into movie values('Harry Potter', 'Family', 'PG');
insert into movie values('Narnia', 'Family', 'U');

DROP TABLE IF EXISTS current_rentals;
CREATE TABLE current_rentals(
    title varchar(100) references movie(title),
    id char(10) references customer(id),
    checkout timestamp,
    expected_return timestamp,
    actual_return timestamp NULL
);
insert into current_rentals values('The Matrix', '111', '2009-02-01','2009-02-16');
insert into current_rentals values('Rambo', '555', '2009-02-11','2009-02-16');
insert into current_rentals values('Saw', '222', '2008-03-11','2008-03-26');
insert into current_rentals values('Kung Fu Panda', '333', '2011-08-17','2010-05-18');
insert into current_rentals values('My Bloody Valentine', '444', '2011-02-11','2011-02-26');
insert into current_rentals values('True Romance', '555', '2011-04-08','2011-08-13');
insert into current_rentals values('Notebook', '222', '2011-08-08','2011-08-13');
insert into current_rentals values('Harry Potter', '111', '2011-08-09','2011-08-23');
insert into current_rentals values('Narnia', '444', '2011-08-17','2011-08-27');
insert into current_rentals values('Bean the movie', '444', '2011-08-17','2011-08-27');

DROP TABLE IF EXISTS historical_rentals;
CREATE TABLE historical_rentals (LIKE current_rentals);

CREATE OR REPLACE FUNCTION new_rental(
    title varchar,
    cust char,
    checkout timestamp,
    expected_return timestamp
) RETURNS void as $$
BEGIN
    PERFORM * from customer where id = cust;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO customer (id) values(cust);
        EXCEPTION 
            WHEN check_violation THEN
                RAISE DEBUG 'Customer id less then three char length';
            RETURN;
        END;
    END IF;

    insert into current_rentals values(title, cust, checkout, expected_return);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION return_rental(
    movie_title varchar,
    cust char,
    return_date timestamp
) RETURNS void as $$
BEGIN
    UPDATE current_rentals set actual_return = return_date where title = movie_title and id = cust;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION archive_rental() RETURNS TRIGGER AS $$
DECLARE
	movie_title varchar;
BEGIN
	select into movie_title  cr.title from current_rentals cr join movie 
    on cr.title=movie.title join genre 
    on movie.genre=genre.name 
    where genre.name = 
    (select genre from movie 
        where title=NEW.title) and cr.actual_return NOTNULL;
    
    IF FOUND THEN
        insert into historical_rentals
        (title,id,checkout,expected_return,actual_return) 
        select cr.title,cr.id, cr.checkout, cr.expected_return,
        cr.actual_return from current_rentals cr
        join movie 
        on cr.title=movie.title 
        join genre
        on movie.genre=genre.name
        where genre.name = (select genre from movie where title=NEW.title)
            and cr.id = NEW.id
            and cr.actual_return NOTNULL;

		Delete from current_rentals cr
		where cr.id = NEW.id 
		and cr.title = movie_title
		and cr.actual_return NOTNULL;
    END IF;
    RETURN NEW;
END;    
$$ LANGUAGE plpgsql;

CREATE TRIGGER supersed_current_rental
    AFTER INSERT ON current_rentals
    FOR EACH ROW EXECUTE PROCEDURE archive_rental();

DROP type time_delta CASCADE;
CREATE TYPE time_delta AS
    (duration double precision);

CREATE OR REPLACE FUNCTION current_rentals_time_delta(varchar) 
                                RETURNS SETOF time_delta AS $$
BEGIN
    IF $1 = 'seconds' THEN
        RETURN query
        select extract('epoch'
        from age(cr.expected_return, cr.checkout)) 
        from current_rentals as cr;
        RETURN;
    ELSEIF $1 = 'days' THEN
        RETURN query
        select round(extract('epoch' 
        from age(cr.expected_return, cr.checkout)/86400)) 
        from current_rentals as cr;
        RETURN;
    ELSEIF $1 = 'default' THEN
        RETURN query
        select extract('epoch' 
        from age(cr.expected_return, cr.checkout)/3600) 
        from current_rentals as cr;
        RETURN;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION array_median(timestamp[]) RETURNS timestamp AS $$
SELECT CASE 
    WHEN mod(array_upper($1,1),2) = 1 THEN 
        asorted[ceiling(array_upper(asorted,1)/2.0)] 
    ELSE 

        asorted[ceiling(array_upper(asorted,1)/2.0)] + 
        age(asorted[ceiling(array_upper(asorted,1)/2.0)+1], asorted[ceiling(array_upper(asorted,1)/2.0)])/2
    END
    FROM 
        (SELECT 
            ARRAY
                (SELECT 
                    ($1)[n] 
                FROM
                    generate_series(1, array_upper($1, 1)) AS n
                WHERE ($1)[n] IS NOT NULL
                ORDER BY ($1)[n]
                ) As asorted
        ) As median;
$$
LANGUAGE 'sql' IMMUTABLE;

DROP AGGREGATE IF EXISTS median(timestamp);
CREATE AGGREGATE median(timestamp) (
      SFUNC=array_append,
      STYPE=timestamp[],
      FINALFUNC=array_median
);

DROP TYPE aggr_dates CASCADE;
CREATE TYPE aggr_dates AS(
    min date,
    max date,
    median date
);

CREATE OR REPLACE FUNCTION aggr_date() RETURNS SETOF aggr_dates as $$
DECLARE
    r aggr_dates%ROWTYPE;
BEGIN
    FOR r in
        select min(date(checkout)), max(date(checkout)), date(median(checkout)) from current_rentals
    LOOP
        return NEXT r;
    end loop;
    return;
END;
$$ LANGUAGE plpgsql rows 1;

DROP TYPE holder CASCADE;
CREATE TYPE holder AS(
    genre varchar(50),
    count bigint
);

CREATE OR REPLACE FUNCTION overdue_underaged() RETURNS SETOF holder AS $$
BEGIN
    RETURN QUERY
        select movie.genre, count(cr.title) from customer join
        current_rentals cr
        on customer.id = cr.id
        join movie
        on cr.title=movie.title
        join pg_rating
        on movie.rating=pg_rating.rating 
        and pg_rating.suggested_age>customer.age
        where cr.actual_return is null and  cr.expected_return < now() 
        group by movie.genre 
        order by count(cr.title) desc;
    RETURN;        
END;
$$ LANGUAGE plpgsql;

DROP TABLE if EXISTS bank_holiday;
CREATE TABLE bank_holiday(
	holiday date
);

insert into bank_holiday values('2009-02-10');

DROP TYPE str_dates CASCADE;
CREATE TYPE str_dates AS(
	dates text
);
CREATE or REPLACE FUNCTION unrented_genre(varchar, st date DEFAULT NULL, ed date DEFAULT NULL) RETURNS SETOF str_dates AS $$
DECLARE
    start_date date;
    end_date date;
	duration interval; 
	days integer;
BEGIN
    IF st is NULL THEN
        start_date := extract(year from now()) || '-' || '01' || '-' || '01';
    ELSE 
        start_date := st;
    END IF;
    IF ed is NULL THEN
        end_date :=  extract(year from now()) || '-' || '12' || '-' || '31';
    ELSE 
        end_date := ed;
    END IF;
	duration := age(end_date, start_date);
	SELECT INTO days floor(EXTRACT('epoch' FROM duration)/86400);
RETURN QUERY 
	SELECT 
			to_char(date, 'Day, dd Month yyyy') 
	FROM
	   (SELECT 
			date
			FROM
				(SELECT generate_series(0,days) + start_date as date) as dayoff
				LEFT OUTER JOIN bank_holiday bh on bh.holiday=dayoff.date
			WHERE 
				bh.holiday is null) dates
			LEFT OUTER JOIN 
				(SELECT 
					cr.title, cr.checkout, m.genre
				 FROM 
					current_rentals cr,
					movie m
				 WHERE
				    m.title=cr.title  
				    AND 
					cr.checkout BETWEEN start_date AND end_date
					AND
					m.genre = $1

					UNION

	         		SELECT 
						hr.title, 
				 	 	hr.checkout, 
					 	m.genre
				   FROM 
						historical_rentals hr,
						movie m
				   WHERE
					   m.title = hr.title  
					   AND 
					   hr.checkout between start_date AND end_date  
					   AND
					   m.genre = $1) as rentals ON (rentals.checkout = dates.date)
	WHERE
			rentals.genre IS NULL;
	RETURN;
END;
$$  LANGUAGE plpgsql;

DROP TYPE promo_type CASCADE;
CREATE TYPE promo_type as(
    dates date,
    day_name text,
    count bigint
);

CREATE or REPLACE FUNCTION promo_report(date, date) RETURNS SETOF promo_type AS $$
BEGIN
    RETURN QUERY
        SELECT 
            promo.date, 
            promo.day_name,
            COALESCE(count(tr.checkout),0) 
        from
            (select
                generate_series(0,20)+ $1 as date,
                to_char(generate_series(0,20) + $1, 'Day') as day_name) as promo 
        LEFT OUTER JOIN 
            (select 
                cr.title, 
                cr.checkout
            from 
                current_rentals cr
            JOIN 
                movie m 
            on 
                m.title=cr.title and m.genre='Family'
            where 
                cr.checkout between $1 AND $2

            UNION

            select 
                hr.title, 
                hr.checkout
            from 
                historical_rentals hr
            JOIN 
                movie m 
            on 
                m.title=hr.title and m.genre='Family'
            where 
                hr.checkout between $1 AND $2) as tr
        on 
            tr.checkout = promo.date
        where 
            promo.day_name LIKE 'Tuesday%' or promo.day_name LIKE 'Wednesday%'
        group by 
            promo.date, promo.day_name
        order by 
        promo.date;
    RETURN;
END;
$$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS query_return CASCADE; 
CREATE TABLE query_return(
    id int primary key,
    name varchar(100)
);
INSERT INTO query_return values(1, 'jav');
INSERT INTO query_return values(2, 'seb');
INSERT INTO query_return values(3, 'mo');

CREATE or REPLACE FUNCTION return_query() RETURNS SETOF query_return as $$
BEGIN
    RETURN QUERY
        SELECT * from query_return;
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE or REPLACE FUNCTION genre_test() RETURNS SETOF genre AS $$
BEGIN
    RETURN QUERY 
        select * from genre;
    RETURN;
END;
$$ LANGUAGE plpgsql;

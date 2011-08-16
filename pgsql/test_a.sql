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
    name varchar(50) primary key
);
insert into genre values('Action');
insert into genre values('Science Fiction');
insert into genre values('Horror');
insert into genre values('Romance');
insert into genre values('Comedy');

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
insert into movie values('Kung Fu Panda', 'Comedy', 'U');
insert into movie values('Bean the movie', 'Comedy', 'PG');
insert into movie values('Die Hard', 'Action', '15');
insert into movie values('Rambo', 'Action', '15');
insert into movie values('True Romance', 'Romance', '18');
insert into movie values('Notebook', 'Romance', '12A');

DROP TABLE IF EXISTS current_rentals;
CREATE TABLE current_rentals(
    title varchar(100) references movie(title),
    id char(10) references customer(id),
    checkout timestamp,
    expected_return timestamp,
    actual_return timestamp NULL
);
--insert into current_rentals values('The Matrix', '111', '2009-02-01','2009-02-16');
insert into current_rentals values('Rambo', '555', '2009-02-11','2009-02-16');
--insert into current_rentals values('Saw', '222', '2008-03-11','2008-03-26');
--insert into current_rentals values('Kung Fu Panda', '333', '2010-04-21','2010-05-18');
--insert into current_rentals values('My Bloody Valentine', '444', '2011-02-11','2011-02-26');
--insert into current_rentals values('True Romance', '555', '2011-08-08','2011-08-13');
--insert into current_rentals values('Notebook', '222', '2011-08-08','2011-08-13');

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

CREATE OR REPLACE FUNCTION aggr_date() RETURNS SETOF DATE as $$
DECLARE
    total integer;
    lower_median date;
    higher_median date;
BEGIN
    total := count(*) from current_rentals;
    RETURN NEXT min(date(checkout)) from current_rentals;
    RETURN NEXT max(date(checkout)) from current_rentals;
    if mod(total, 2) = 1 then
        RETURN NEXT date(checkout) 
            from (select row_number() 
            over (order by checkout) as row, checkout
            from current_rentals) as tableone
            where row=(select count(*)/2+1 from current_rentals);
        
    else 
        lower_median := date(checkout) 
            from (select row_number() 
            over (order by checkout) as row, checkout
            from current_rentals) as tableone
            where row=(select count(*)/2 from current_rentals);
        higher_median := date(checkout) 
            from (select row_number() 
            over (order by checkout) as row, checkout
            from current_rentals) as tableone
            where row=(select count(*)/2+1 from current_rentals);            
        RETURN NEXT lower_median + age(higher_median, lower_median)/2;
    end if;
END;
$$ LANGUAGE plpgsql;

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

--CREATE or REPLACE FUNCTION unrented_genre(datetime, datetime, genre varchar) RETURNS 
 select to_char(date, 'Day, dd Month yyyy')
  2     from
  3         (select date, movie.genre
  4         from
  5             (select date, title, checkout
  6             from
  7                 (select date
  8                 from
  9                     (select generate_series(0,10) + date '2009-02-01' as date)
 10             as dayoff
 11             left join bank_holiday bh on bh.holiday=dayoff.date
 12             where bh.holiday is null) dates
 13             left join
 14             (select cr.title, cr.checkout
 15                 from current_rentals cr
 16                 where cr.checkout between date '2009-02-01' and date '2009-02-12'
 17                 union
 18                 select hr.title, hr.checkout
 19                 from historical_rentals hr
 20                 where  hr.checkout between date '2009-02-01' and date '2009-02-12')
 21             as rentals
 22         on dates.date=rentals.checkout)
 23     as all_rentals left join movie
 24     on movie.title = all_rentals.title) as results
 25 where results.genre <> 'Science Fiction' or results.genre is null;


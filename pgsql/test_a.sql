DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
    id char(10) primary key CHECK (char_length(id) >= 3),
    fname varchar(30),
    lname varchar(30),
    age integer
);
insert into customer values('111','Argotte', 'Javier', 28);
insert into customer values('222', 'Blair', 'Tony', 31);
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
    rating varchar(10) primary key
);
insert into pg_rating values('U');
insert into pg_rating values('PG');
insert into pg_rating values('12');
insert into pg_rating values('12A');
insert into pg_rating values('15');
insert into pg_rating values('18');
insert into pg_rating values('18R');

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
insert into movie values('Notting Hill', 'Romance', '12A');
insert into movie values('Notebook', 'Romance', '12A');

DROP TABLE IF EXISTS current_rentals;
CREATE TABLE current_rentals(
    title varchar(100) references movie(title),
    id char(10) references customer(id),
    rent_date timestamp,
    expected_return timestamp,
    actual_return timestamp NULL
);
insert into current_rentals values('The Matrix', '111', '2011-08-08','2011-08-18');
insert into current_rentals values('Saw', '222', '2011-08-08','2011-08-18');
insert into current_rentals values('Kung Fu Panda', '333', '2011-08-08','2011-08-18');
insert into current_rentals values('Die Hard', '444', '2011-08-08','2011-08-18');
insert into current_rentals values('Notting Hill', '555', '2011-08-08','2011-08-18');

DROP TABLE IF EXISTS historical_rentals;
CREATE TABLE historical_rentals (LIKE current_rentals);

CREATE OR REPLACE FUNCTION new_rental(
    title varchar,
    cust char,
    rent_date timestamp,
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

    insert into current_rentals values(title, cust, rent_date, expected_return);

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
BEGIN
    PERFORM cr.title from current_rentals cr join movie 
    on cr.title=movie.title join genre 
    on movie.genre=genre.name 
    where genre.name = 
    (select genre from movie 
        where title=NEW.title) and cr.actual_return NOTNULL;
    IF FOUND THEN
        insert into historical_rentals
        (title,id,rent_date,expected_return,actual_return) 
        select cr.title,cr.id, cr.rent_date, cr.expected_return,
        cr.actual_return from current_rentals cr
        join movie 
        on cr.title=movie.title 
        join genre
        on movie.genre=genre.name
        where genre.name = (select genre from movie where title=NEW.title)
            and cr.id = NEW.id
            and cr.actual_return NOTNULL;
    END IF;
    RETURN NEW;
END;    
$$ LANGUAGE plpgsql;

CREATE TRIGGER supersed_current_rental
    AFTER INSERT ON current_rentals
    FOR EACH ROW EXECUTE PROCEDURE archive_rentals();

DROP type time_delta CASCADE;
CREATE TYPE time_delta AS
    (duration double precision);

CREATE OR REPLACE FUNCTION current_rentals_time_delta(varchar) 
                                RETURNS SETOF time_delta AS $$
BEGIN
    IF $1 = 'seconds' THEN
        RETURN query
        select extract('epoch'
        from age(cr.expected_return, cr.rent_date)) 
        from current_rentals as cr;
        RETURN;
    ELSEIF $1 = 'days' THEN
        RETURN query
        select extract('epoch' 
        from age(cr.expected_return, cr.rent_date)/86400) 
        from current_rentals as cr;
        RETURN;
    ELSEIF $1 = 'default' THEN
        RETURN query
        select extract('epoch' 
        from age(cr.expected_return, cr.rent_date)/3600) 
        from current_rentals as cr;
        RETURN;
    END IF;
END;
$$ LANGUAGE plpgsql;

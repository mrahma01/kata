DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
    id serial primary key,
    fname varchar(30),
    lname varchar(30),
    age integer
);
insert into customer(fname, lname, age) values('Argotte', 'Javier', 28);
insert into customer(fname, lname, age) values('Blair', 'Tony', 31);
insert into customer(fname, lname, age) values('Obama', 'Barack', 15);
insert into customer(fname, lname, age) values('Jobs', 'Steve', 11);
insert into customer(fname, lname, age) values('Gates', 'Bill', 13);


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
    name varchar(50) references genre(name),
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
    id serial references customer(id),
    rent_date timestamp,
    expected_return timestamp,
    actual_return timestamp NULL
);
insert into current_rentals values('The Matrix', 1, '2011-08-08','2011-08-18');
insert into current_rentals values('Saw', 2, '2011-08-08','2011-08-18');
insert into current_rentals values('Kung Fu Panda', 3, '2011-08-08','2011-08-18');
insert into current_rentals values('Die Hard', 4, '2011-08-08','2011-08-18');
insert into current_rentals values('Notting Hill', 5, '2011-08-08','2011-08-18');

DROP TABLE IF EXISTS historical_rentals;
CREATE TABLE historical_rentals (LIKE current_rentals);

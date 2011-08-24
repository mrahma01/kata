DROP TABLE IF EXISTS genre CASCADE;
CREATE TABLE genre (
    name varchar(50) primary key,
    details varchar(100),
    day_added date
);
insert into genre values('Action');
insert into genre values('Science Fiction');
insert into genre values('Horror');
insert into genre values('Romance');
insert into genre values('Family');


CREATE or REPLACE FUNCTION no_results() RETURNS SETOF genre AS $$
BEGIN
    RETURN QUERY 
        SELECT 
            * 
        FROM genre 
        WHERE name LIKE '%Axxion';
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE or REPLACE FUNCTION single_row() RETURNS SETOF genre AS $$
BEGIN
    RETURN QUERY 
        SELECT 
            * 
        FROM genre 
        WHERE name LIKE '%Action';
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE or REPLACE FUNCTION genre_names() RETURNS SETOF genre AS $$
BEGIN
    RETURN QUERY 
        SELECT 
            * 
        FROM genre; 
    RETURN;
END;
$$ LANGUAGE plpgsql;


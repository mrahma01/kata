CREATE OR REPLACE FUNCTION getcity(int) RETURNS SETOF weather AS $$
    SELECT * FROM weather WHERE temp_lo > $1;
    $$ LANGUAGE SQL;

CREATE OR REPlACE FUNCTION somefunc() RETURNS integer AS $$
<<outerblock>>
DECLARE
    quantity integer := 30;
BEGIN
    RAISE NOTICE '1. Quantity is %', quantity;
    quantity := 50;
    DECLARE
        quantity integer :=80;
    BEGIN
        RAISE NOTICE '2. quantity here is %', quantity;
        RAISE NOTICE '3. quantity here is %', outerblock.quantity;
    END;
    RAISE NOTICE '4. quantity is %', quantity;
    RETURN quantity;
END;
$$ LANGUAGE plpgsql;

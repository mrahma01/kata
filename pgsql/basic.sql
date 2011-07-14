-- my first plpgsql function
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

-- function to return a base type
CREATE OR REPLACE FUNCTION sales_tax(subtotal real, OUT tax real) AS $$
BEGIN
    tax := subtotal * 0.20;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION instr(varchar, integer) RETURNS integer AS $$
DECLARE
    v_string ALIAS FOR $1;
    index ALIAS FOR $2;
BEGIN
    RAISE NOTICE '% is %', v_string, index;
    RETURN index;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sum_n_product
    (x int, y int, OUT sum int, OUT prod int) AS $$
BEGIN
    sum := x + y;
    prod := x* y;
END
$$ LANGUAGE plpgsql;

-- funciton to return anyelement
CREATE OR REPLACE FUNCTION add_three_numbers
    (n1 anyelement, n2 anyelement, n3 anyelement) RETURNS anyelement AS $$
DECLARE
    result ALIAS FOR $0;
BEGIN
    result := n1 + n2 + n3;
    return result;
END;
$$ LANGUAGE plpgsql;

-- function to work with optional argument
CREATE OR REPLACE FUNCTION foo(a int, b int DEFAULT 2, c int DEFAULT 3)
    RETURNS int AS $$
BEGIN
    return $1 + $2 + $3;
END;
$$ LANGUAGE plpgsql;

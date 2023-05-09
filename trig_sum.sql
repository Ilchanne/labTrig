CREATE FUNCTION calc_sum () RETURNS TRIGGER LANGUAGE 'plpgsql' AS
$$
BEGIN 
	NEW.s = New.a + New.b;
	RETURN New;
END
$$;

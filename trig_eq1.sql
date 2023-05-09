create function solve_equation_o() returns trigger language 'plpgsql' as
$$
Declare
	d float;
Begin
	If TG_OP = 'DELETE' then
	insert into logs (evt) values ('equation deleted');
	return OLD;
	End If;

	d = NEW.b * NEW.b - 4.0 * NEW.a * NEW.c;

	If d <0.0 Then
	return NEW;
	End If;

	If d > 0.0 Then
	New.x0 = (-NEW.b - sqrt(d))/(2.0 * NEW.a);
	New.x1 = (-NEW.b + sqrt(d))/(2.0 * NEW.a);
	Return NEW;
	End If;

	NEW.x0 = -NEW.b / (2.0 * NEW.a);
	Return NEW;
End
$$;

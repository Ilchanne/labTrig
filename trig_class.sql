create or replace function kmeans_classify() returns trigger language 'plpgsql' as
$$
Declare
        d0 float;
        d1 float;
        cx0 float = 6.2;
        cy0 float = 7.0;
        cx1 float = 2.0;
        cy1 float = 1.8;
begin
        d0 = sqrt((cx0 - NEW.x)*(cx0-NEW.x)+(cy0-NEW.y)*(cy0-NEW.y));
        d1 = sqrt((cx1 - NEW.x)*(cx1-NEW.x)+(cy1-NEW.y)*(cy1-NEW.y));

        If d0 < d1 then
        NEW.z = 0;
        else
        NEW.z = 1;
        End if;

        return NEW;
End
$$;

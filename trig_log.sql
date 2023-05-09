create function log_event() returns trigger language 'plpgsql' as
$$
Begin
	insert into logs(evt) values (concat('account"',OLD.usr, '"deleted'));
	return OLD;
End
$$;
create function log_nevent() returns trigger language 'plpgsql' as
$$
begin
	if OLD.usr = 'admin' then
	insert into logs (evt) values ('an attempt to delete admin account');
	raise notice 'this will be reported';
	return null;
	end if;
	insert into logs (evt) values (concat('account"',OLD.usr,'"deleted'));
	return OLD;
end
$$;

Create function calc_hash () returns trigger language 'plpgsql' AS
$$
Begin
	New.pass = md5(New.pass);
	Return New;
End
$$

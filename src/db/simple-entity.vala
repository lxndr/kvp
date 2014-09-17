namespace DB {


public abstract class SimpleEntity : Entity {
	public int64 id { get; set; default = 0; }


	construct {
		id = 0;
	}


	public override string[] db_keys () {
		return {
			"id"
		};
	}


	public override void remove () {
		if (id == 0)
			error ("The entity being removed is not present in the database.");

		var query = ("DELETE FROM %s WHERE id=%" + int64.FORMAT)
				.printf (db_table (), id);
		db.exec_sql (query, null);
	}
}


}

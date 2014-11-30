namespace DB {


public abstract class SimpleEntity : Entity {
	public int id { get; set; default = 0; }


	construct {
		id = 0;
	}


	public override unowned string[] db_keys () {
		const string keys[] = {
			"id"
		};
		return keys;
	}


	public override void remove () {
		if (id == 0)
			error ("The entity being removed is not present in the database.");

		db.delete_entity (this);
	}
}


}

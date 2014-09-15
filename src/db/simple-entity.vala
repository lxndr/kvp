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
}


}

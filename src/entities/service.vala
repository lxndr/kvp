namespace Kv {


public class Service : Entity
{
	public int64 id { get; set; }
	public string name { get; set; }
	public string? unit { get; set; }
	public int applied_to { get; set; }


	static construct {
		table_name = "services";
	}


	construct {
		id = 0;
		name = "";
		unit = null;
		applied_to = 0;
	}


	public override string get_display_name () {
//		return name;
		return table_name;
	}

/*
	public override string[] db_keys () {
		return {
			"id"
		};
	}


	public override string[] db_fields () {
		return {
			"name",
			"unit",
			"applied_to"
		};
	}*/
}


public int main () {
	var e = new Service ();
	unowned string str1 = e.table_name;
	stdout.printf ("STR1 %s\n", str1);

	var type = typeof (Service);
	unowned TypeClass klass = type.class_peek ();

	unowned string str2 = Entity.table_name;

//	var entity_class = (Entity) klass;
//	unowned string str2 = entity_class.table_name;
//	stdout.printf ("STR2 %s\n", str2);

	return 0;
}


}

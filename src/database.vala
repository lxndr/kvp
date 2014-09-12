namespace Kv {


public errordomain DatabaseError {
	OPENING_FAILED,
	EXEC_FAILED
}


public class Database : Object {
	private Sqlite.Database db;

	public Database () throws Error {
		/* open the database */
		int ret = Sqlite.Database.open_v2 ("./kvartplata.db", out db);
		if (ret != Sqlite.OK)
			throw new DatabaseError.OPENING_FAILED (
					"Error opening the database: (%d) %s", db.errcode (), db.errmsg ());

		/* prepare the database */
		var bytes = resources_lookup_data ("/data/init.sql", ResourceLookupFlags.NONE);
		unowned uint8[] data = bytes.get_data ();
		exec_sql ((string) data);
	}


	private void exec_sql (string sql, Sqlite.Callback? callback = null) {
		string errmsg;
		stdout.printf ("%s\n", sql);
		if (db.exec (sql, callback, out errmsg) != Sqlite.OK)
			error ("Error executing SQL statement: %s\n", errmsg);
	}


	public string? get_setting (string key) {
		var query = "SELECT * FROM settings WHERE key='%s'".printf (key);
		string? val = null;

		exec_sql (query, (n_columns, values, column_names) => {
			val = values[0];
			return 0;
		});

		return val;
	}


	public void set_setting (string key, string val) {
		var query = "REPLACE INTO settings VALUES ('%s', '%s')".printf (key, val);
		exec_sql (query);
	}


	public Entity get_entity (Type type, int64 id) {
		var tmp = Object.new (type) as Entity;
		var query = "SELECT * FROM `%s` WHERE id=%lld".printf (tmp.db_table_name (), id);

		var list = get_entity_list (type, query);
		return list[0];
	}


	public Gee.List<Service> get_service_list () {
		return get_entity_list (typeof (Service), "SELECT * FROM services") as Gee.List<Service>;
	}


	public Gee.List<Account> get_account_list () {
		return get_entity_list (typeof (Account), "SELECT * FROM accounts") as Gee.List<Account>;
	}


	public Gee.List<Person> get_people_list (Period period, Account account) {
		var query = "SELECT * FROM people WHERE year=%d AND month=%d AND account=%lld"
				.printf (period.year, period.month, account.id);
		return get_entity_list (typeof (Person), query) as Gee.List<Person>;
	}


	public Gee.List<Tax> get_tax_list (Period period, Account account) {
		var query = "SELECT * FROM taxes WHERE year=%d AND month=%d AND account=%lld"
				.printf (period.year, period.month, account.id);
		return get_entity_list (typeof (Tax), query) as Gee.List<Tax>;
	}


	private Gee.List<Entity> get_entity_list (Type type, string sql) {
		var obj_class = (ObjectClass) type.class_ref ();
		var list = new Gee.ArrayList<Entity> ();
		var str_val = Value (typeof (string));

		exec_sql (sql, (n_columns, values, column_names) => {
			var entity = Object.new (type) as Entity;
			for (var i = 0; i < n_columns; i++) {
				unowned string prop_name = column_names[i];
				var prop = obj_class.find_property (prop_name);
				if (prop == null)
					error ("Could not find propery '%s' in '%s'", prop_name, type.name ());
				var prop_type = prop.value_type;

				str_val.set_string (values[i]);
				var dest_val = Value (prop_type);

				if (prop_type.is_a (typeof (Entity)))
					dest_val.set_object (get_entity (prop_type, int64.parse (values[i])));
				else if (str_val.transform (ref dest_val) == false)
					stdout.printf ("Couldn't transform from '%s' to '%s' for property '%s' of '%s'\n",
							str_val.type ().name (), dest_val.type ().name (),
							prop_name, type.name ());

				entity.set_property (column_names[i], dest_val);
			}
			entity.changed = false;
			list.add (entity);
			return 0;
		});

		return list;
	}


	private string prepare_insert_values (Entity entity, string[] props, ObjectClass obj_class) {
		string values = "";

		foreach (unowned string prop_name in props) {
			var prop_spec = obj_class.find_property (prop_name);
			var val = Value (prop_spec.value_type);
			entity.get_property (prop_name, ref val);

			/* the ID of an Entity */
			if (val.type ().is_a (typeof (Entity))) {
				var obj = val.get_object () as Entity;
				val = Value (typeof (int64));
				obj.get_property ("id", ref val);
			}

			var str_val = Value (typeof (string));
			if (val.transform (ref str_val) == false)
				stdout.printf ("Couldn't transform from '%s' to '%s' for property '%s' of '%s'\n",
						val.type ().name (), str_val.type ().name (),
						prop_name, prop_spec.value_type.name ());

			if (val.type () == typeof (string))
				values += ", '%s'".printf (str_val.get_string ());
			else
				values += ", %s".printf (str_val.get_string ());
		}

		return values;
	}


	private string prepare_update_values (Entity entity, string[] props, ObjectClass obj_class) {
		string values = "";

		foreach (unowned string prop_name in props) {
			var prop_spec = obj_class.find_property (prop_name);
			var val = Value (prop_spec.value_type);
			entity.get_property (prop_name, ref val);

			/* the ID of an Entity */
			if (val.type ().is_a (typeof (Entity))) {
				var obj = val.get_object () as Entity;
				val = Value (typeof (int64));
				obj.get_property ("id", ref val);
			}

			var str_val = Value (typeof (string));
			if (val.transform (ref str_val) == false)
				stdout.printf ("Couldn't transform from '%s' to '%s' for property '%s' of '%s'\n",
						val.type ().name (), str_val.type ().name (),
						prop_name, prop_spec.value_type.name ());

			if (val.type () == typeof (string))
				values += "`%s`='%s', ".printf (prop_name, str_val.get_string ());
			else
				values += "`%s`=%s, ".printf (prop_name, str_val.get_string ());
		}

		return values[0:-2];
	}


	private void persist_auto_key (Entity entity, string[] fields, ObjectClass obj_class) {
		var id_val = Value (typeof (int64));
		entity.get_property ("id", ref id_val);
		var entity_id = id_val.get_int64 ();

		if (entity_id == 0) {
			var query = "INSERT INTO `%s` VALUES (NULL%s)".printf (entity.db_table_name (),
					prepare_insert_values (entity, fields, obj_class));
			exec_sql (query);
			entity.set_property ("id", db.last_insert_rowid ());
		} else {
			var query = "UPDATE `%s` SET %s WHERE `id`=%lld".printf (entity.db_table_name (),
					prepare_update_values (entity, fields, obj_class), entity_id);
			exec_sql (query);
		}
	}


	private void persist_composite_key (Entity entity, string[] keys, string[] fields, ObjectClass obj_class) {
		var values = "";

		foreach (var prop_name in keys) {
			var prop_spec = obj_class.find_property (prop_name);
			var val = Value (prop_spec.value_type);
			entity.get_property (prop_name, ref val);

			if (val.type ().is_a (typeof (Entity))) {
				var obj = val.get_object () as Entity;
				val = Value (typeof (int64));
				obj.get_property ("id", ref val);
			}

			var str_val = Value (typeof (string));
			if (val.transform (ref str_val) == false)
				stdout.printf ("Couldn't transform from '%s' to '%s' for property '%s' of '%s'\n",
						val.type ().name (), str_val.type ().name (),
						prop_name, prop_spec.value_type.name ());

			if (val.type () == typeof (string))
				values += "'%s', ".printf (str_val.get_string ());
			else
				values += "%s, ".printf (str_val.get_string ());
		}

		foreach (var prop_name in fields) {
			var prop_spec = obj_class.find_property (prop_name);
			var val = Value (prop_spec.value_type);
			entity.get_property (prop_name, ref val);

			if (val.type ().is_a (typeof (Entity))) {
				var obj = val.get_object () as Entity;
				val = Value (typeof (int64));
				obj.get_property ("id", ref val);
			}

			var str_val = Value (typeof (string));
			if (val.transform (ref str_val) == false)
				stdout.printf ("Couldn't transform from '%s' to '%s' for property '%s' of '%s'\n",
						val.type ().name (), str_val.type ().name (),
						prop_name, prop_spec.value_type.name ());

			if (val.type () == typeof (string))
				values += "'%s', ".printf (str_val.get_string ());
			else
				values += "%s, ".printf (str_val.get_string ());
		}

		values = values[0:-2];

		var query = "REPLACE INTO `%s` VALUES (%s)".printf (entity.db_table_name (), values);
		exec_sql (query);
	}


	public void persist (Entity entity) {
		var keys = entity.db_keys ();
		var fields = entity.db_fields ();

		var obj_class = (ObjectClass) entity.get_type ().class_ref ();

		if (keys.length == 1 && keys[0] == "id")
			persist_auto_key (entity, fields, obj_class);
		else
			persist_composite_key (entity, keys, fields, obj_class);
	}
}


}

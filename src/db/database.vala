namespace DB {


public interface Database : Object {
	public abstract void exec_sql (string sql, Sqlite.Callback? callback = null);
	public abstract int64 last_insert_rowid ();


	public int64 query_count (string table, string expr) {
		int64 result = 0;
		var query = "SELECT COUNT(*) FROM `%s` WHERE %s"
				.printf (table, expr);

		exec_sql (query, (n_columns, values, column_names) => {
			if (values[0] != null)
				result = int64.parse (values[0]);
			return 0;
		});

		return result;
	}


	public string? query_string (string table, string column, string expr) {
		string? result = null;
		var query = "SELECT `%s` FROM `%s` WHERE %s"
				.printf (column, table, expr);

		exec_sql (query, (n_columns, values, column_names) => {
			result = values[0];
			return 0;
		});

		return result;
	}


	public T? fetch_entity<T> (string table, string expr) {
		var query = "SELECT * FROM %s WHERE %s LIMIT 1"
				.printf (table, expr);
		var list = get_entity_list (typeof (T), query) as Gee.List<T>;
		if (list.size == 0)
			return null;
		return list[0];
	}


	public DB.Entity get_entity (Type type, int64 id) {
		var tmp = Object.new (type) as DB.Entity;
		var query = "SELECT * FROM `%s` WHERE id=%lld".printf (tmp.db_table (), id);

		var list = get_entity_list (type, query);
		return list[0];
	}


	public Gee.List<DB.Entity> get_entity_list (Type type, string? _sql) {
		string sql;

		if (_sql == null) {
			var tmp = Object.new (type) as Entity;
			var table = tmp.db_table ();
			sql = "SELECT * FROM `%s`".printf (table);
		} else {
			sql = _sql;
		}

		var obj_class = (ObjectClass) type.class_ref ();
		var list = new Gee.ArrayList<DB.Entity> ();
		var str_val = Value (typeof (string));

		exec_sql (sql, (n_columns, values, column_names) => {
			var entity = Object.new (type, "db", this) as DB.Entity;
			for (var i = 0; i < n_columns; i++) {
				unowned string prop_name = column_names[i];
				var prop = obj_class.find_property (prop_name);
				if (prop == null)
					error ("Could not find propery '%s' in '%s'", prop_name, type.name ());
				var prop_type = prop.value_type;

				str_val.set_string (values[i]);
				var dest_val = Value (prop_type);

				if (prop_type.is_a (typeof (DB.Entity)))
					dest_val.set_object (get_entity (prop_type, int64.parse (values[i])));
				else if (str_val.transform (ref dest_val) == false)
					warning ("Couldn't transform value '%s' from '%s' to '%s' for property '%s' of '%s'\n",
							values[i], str_val.type ().name (), dest_val.type ().name (),
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
			var query = "INSERT INTO `%s` VALUES (NULL%s)".printf (entity.db_table (),
					prepare_insert_values (entity, fields, obj_class));
			exec_sql (query);
			entity.set_property ("id", last_insert_rowid ());
		} else {
			var query = "UPDATE `%s` SET %s WHERE `id`=%lld".printf (entity.db_table (),
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
				warning ("Couldn't transform from '%s' to '%s' for property '%s' of '%s'\n",
						val.type ().name (), str_val.type ().name (),
						prop_name, prop_spec.value_type.name ());

			if (val.type () == typeof (string))
				values += "'%s', ".printf (str_val.get_string ());
			else
				values += "%s, ".printf (str_val.get_string ());
		}

		values = values[0:-2];

		var query = "REPLACE INTO `%s` VALUES (%s)".printf (entity.db_table (), values);
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

namespace DB {


public interface Database : Object {
	public abstract void exec_sql (string sql, Sqlite.Callback? callback = null);
	public abstract int64 last_insert_rowid ();


	public string build_select_query (string table, string? columns = null,
			string? where = null, string? order_by = null, int limit = -1,
			string? extra = null) {
		var sb = new StringBuilder ("SELECT ");

		if (columns == null)
			sb.append_printf ("* FROM %s", table);
		else
			sb.append_printf ("%s FROM %s", columns, table);

		if (where != null)
			sb.append_printf (" WHERE %s", where);
		if (order_by != null)
			sb.append_printf (" ORDER BY %s", order_by);
		if (limit > -1)
			sb.append_printf (" LIMIT %d", limit);
		if (extra != null)
			sb.append_printf (" %s", extra);

		return sb.str;
	}


	public string? fetch_string (string table, string column, string where) {
		string? result = null;

		var query = build_select_query (table, column, where);
		exec_sql (query, (n_columns, values, column_names) => {
			result = values[0];
			return 0;
		});

		return result;
	}


	public int64 fetch_int64 (string table, string column, string where) {
		int64 n = 0;
		var s = fetch_string (table, column, where);
		if (s != null)
			n = int64.parse (s);
		return n;
	}


	public int64 query_count (string table, string? where) {
		return fetch_int64 (table, "COUNT(*)", where);
	}


	public int64 query_sum (string table, string column, string where) {
		return fetch_int64 (table, "SUM(%s)".printf (column), where);
	}


	private void prepare_entity (Entity ent, int n_fields,
			[CCode (array_length = false)] string[] fields,
			[CCode (array_length = false)] string[] values,
			bool recursive = true) {
		var type = ent.get_type ();
		var obj_class = (ObjectClass) type.class_ref ();

		var str_val = Value (typeof (string));

		for (var i = 0; i < n_fields; i++) {
			unowned string prop_name = fields[i];
			var prop = obj_class.find_property (prop_name);
			if (prop == null)
				error ("Could not find propery '%s' in '%s'", prop_name, type.name ());
			var prop_type = prop.value_type;

			str_val.set_string (values[i]);
			var dest_val = Value (prop_type);

			if (prop_type.is_a (typeof (DB.Entity))) {
				Entity? obj = null;
				if (recursive == true) {
					var obj_id = int64.parse (values[i]);
					if (obj_id > 0)
						obj = fetch_entity_full (prop_type, null,
								("id=%" + int64.FORMAT).printf (obj_id));
				}
				dest_val.set_object (obj);
			} else if (str_val.transform (ref dest_val) == false) {
				warning ("Couldn't transform value '%s' from '%s' to '%s' for property '%s' of '%s'\n",
						values[i], str_val.type ().name (), dest_val.type ().name (), prop_name, type.name ());
			}

			ent.set_property (prop_name, dest_val);
		}
	}


	private Entity? fetch_entity_full (Type type, string? table, string where, bool recursive = true) {
		bool found = false;
		var ent = Object.new (type, "db", this) as Entity;

		if (table == null)
			table = ent.db_table ();

		var query = build_select_query (table, null, where, null, 1);
		exec_sql (query, (n_columns, values, column_names) => {
			prepare_entity (ent, n_columns, column_names, values, recursive);
			found = true;
			return 0;
		});

		if (found == false)
			return null;
		return ent;
	}


	public T? fetch_entity<T> (string table, string where, bool recursive = true) {
		return fetch_entity_full (typeof (T), table, where, recursive);
	}


	public T? fetch_entity_by_id<T> (int64 id, string? table = null, bool recursive = true) {
		return fetch_entity<T> (table, ("id=%" + int64.FORMAT).printf (id));
	}


	public Entity make_entity_full (Type type, int n_fields,
			[CCode (array_length = false)] string[] fields,
			[CCode (array_length = false)] string[] values,
			bool recursive = true) {
		var ent = Object.new (type, "db", this) as Entity;
		prepare_entity (ent, n_fields, fields, values, recursive);
		return ent;
	}


	public T make_entity<T> (int n_fields,
			[CCode (array_length = false)] string[] fields,
			[CCode (array_length = false)] string[] values,
			bool recursive = true) {
		return make_entity_full (typeof (T), n_fields, fields, values, recursive);
	}


	public Gee.List<Entity> fetch_entity_list_full (Type type, string? table = null,
			string? where = null, string? order_by = null, int limit = -1,
			bool recursive = true) {
		if (table == null) {
			var tmp = Object.new (type) as Entity;
			table = tmp.db_table ();
		}

		var list = new Gee.ArrayList<Entity> ();
		var query = build_select_query (table, null, where, order_by, limit);
		exec_sql (query, (n_columns, values, column_names) => {
			list.add (make_entity_full (type, n_columns, column_names, values, recursive));
			return 0;
		});
		return list;
	}


	public Gee.List<T> fetch_entity_list<T> (string table, string? where = null,
			string? order_by = null, int limit = -1, bool recursive = true) {
		return fetch_entity_list_full (typeof (T), table, where, order_by, limit, recursive);
	}


	public Gee.Map<int, T> fetch_int_entity_map<T> (string table, string key_field,
			string? where = null) {
		int key_column = -1;

		/* query */
		var sb = new StringBuilder ();
		sb.append_printf ("SELECT * FROM %s", table);
		if (where != null)
			sb.append_printf (" WHERE %s", where);

		var map = new Gee.HashMap<int, T> ();
		exec_sql (sb.str, (n_columns, values, column_names) => {
			if (key_column == -1) {
				for (var i = 0; i < n_columns; i++)
					if (column_names[i] == key_field)
						key_column = i;
				if (key_column == -1)
					error ("Table '%s' doesn't have column '%s'", table, key_field);
			}

			var key = (int) int64.parse (values[key_column]);
			map[key] = make_entity<T> (n_columns, column_names, values);
			return 0;
		});
		return map;
	}


	public void delete_entity (string table, string where) {
		exec_sql ("DELETE FROM %s WHERE %s".printf (table, where), null);
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
			} else if (val.type () == typeof (bool)) {
				var b = (int64) val.get_boolean ();
				val = Value (typeof (int64));
				val.set_int64 (b);
			} else if (val.type () == typeof (double)) {
				char[] buf = new char[double.DTOSTR_BUF_SIZE];
				unowned string str = val.get_double ().to_str (buf);
				val = Value (typeof (string));
				val.set_string (str);
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

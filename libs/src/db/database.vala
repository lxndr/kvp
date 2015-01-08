namespace DB {


public class Database : Object {
	public Engine engine { private get; construct set; }
	public ValueAdapter value_adapter { get; set; }
	private Gee.HashMap<Type, unowned EntitySpec> entity_types;
	private Gee.HashMap<Type, Gee.HashMap<int, Entity>> cache;


	construct {
		entity_types = new Gee.HashMap<Type, EntitySpec> ();
		cache = new Gee.HashMap<Type, Gee.HashMap<int, Entity>> ();
	}


	public Database (Engine _engine) {
		Object (engine: _engine);
	}


	/*
	 * Helpers.
	 */
	public void exec_sql (string sql, Sqlite.Callback? callback = null) {
		engine.exec_sql (sql, callback);
	}


	public void exec (Query query) {
		engine.exec_sql (query.sql ());
	}


	private T wrap_value<T> (ref Value val) {
		var t = typeof (T);
		if (t == typeof (bool))
			return val.get_boolean ();
		if (t == typeof (char))
			return val.get_char ();
		if (t == typeof (int8))
			return val.get_schar ();
		if (t == typeof (uchar))
			return val.get_uchar ();
		if (t == typeof (int))
			return val.get_int ();
		if (t == typeof (uint))
			return val.get_uint ();
		if (t == typeof (long))
			return val.get_long ();
		if (t == typeof (ulong))
			return val.get_ulong ();
		if (t == typeof (int64))
			return val.get_int64 ();
		if (t == typeof (uint64))
			return val.get_uint64 ();
		/* TODO: float, double, string, boxed, object */
		return val.peek_pointer ();
	}


	/*
	 * Entity specs registry.
	 */
	public unowned EntitySpec register_entity_type (Type type, string table_name) {
		entity_types[type] = new EntitySpec (type, table_name);
		return entity_types[type];
	}


	public void unregister_entity_type (Type type) {
		entity_types.unset (type);
	}


	public unowned EntitySpec find_entity_spec (Type type) {
		return entity_types[type];
	}



	/*
	 * Cache.
	 */
	public Entity? get_from_cache_simple (Type type, int id) {
		var list = cache[type];
		if (list == null)
			return null;
		return list[id];
	}


	public void set_cachable (Type type, bool cachable) {
		if (cachable) {
			if (cache[type] == null)
				cache[type] = new Gee.HashMap<int, Entity> ();
		} else {
			cache.unset (type);
		}
	}


	public void cache_entity_simple (SimpleEntity entity) {
		var list = cache[entity.get_type ()];
		if (list == null)
			return;

		assert (!list.has_key (entity.id));
		list[entity.id] = entity;
	}



	/*
	 * Selection.
	 */
	public Gee.List<Entity> fetch_entity_list_full (Type type, Query query) {
		var list = new Gee.ArrayList<Entity> ();

		engine.exec_sql (query.sql (), (n_columns, values, column_names) => {
			list.add (make_entity_full (type, n_columns, column_names, values));
			return 0;
		});

		return list;
	}


	public Gee.List<T> fetch_entity_list<T> (Query query) {
		return fetch_entity_list_full (typeof (T), query);
	}


	public Entity? fetch_entity_full (Type type, Query query) {
		var list = fetch_entity_list_full (type, query);
		if (list.size > 0)
			return list[0];
		return null;
	}


	public T? fetch_entity<T> (Query query) {
		return fetch_entity_full (typeof (T), query);
	}


	public Entity? fetch_simple_entity_full (Type type, int id, string? table = null) {
		var entity = get_from_cache_simple (type, id);
		if (entity != null)
			return entity;

		if (table == null)
			table = find_entity_spec (type).table_name;

		var query = new Query.select ();
		query.from (table)
			.where (@"id = $(id)");
		return fetch_entity_full (type, query);
	}


	public T? fetch_simple_entity<T> (int id, string? table = null) {
		return fetch_simple_entity_full (typeof (T), id, table);
	}


	public T fetch_value<T> (Query query, T def) {
		var list = fetch_value_list<T> (query);
		if (list.size > 0)
			return list[0];
		return def;
	}


	/**
	 * @brief Fetch a list of values of type @T.
	 * @query The query.
	 */
	public Gee.List<T> fetch_value_list<T> (Query query) {
		var list = new Gee.ArrayList<T> ();

		engine.exec_sql (query.sql (), (n_columns, values, column_names) => {
			var val = Value (typeof(T));
			if (!assemble_value (ref val, values[0]))
				warning ("-");
			list.add (wrap_value<T> (ref val));
			return 0;
		});

		return list;
	}


	public Gee.Map<K, T> fetch_entity_map<K, T> (Query query, string key_field) {
		int key_column = -1;

		var map = new Gee.HashMap<K, T> ();
		engine.exec_sql (query.sql (), (n_columns, values, column_names) => {
			if (key_column == -1) {
				for (var i = 0; i < n_columns; i++)
					if (column_names[i] == key_field)
						key_column = i;
				if (key_column == -1)
					error (@"Doesn't have column '$(key_field)'");
			}

			var key_value = Value (typeof (K));
			assemble_value (ref key_value, values[key_column]);
			var key = wrap_value<K> (ref key_value);

			var val = make_entity<T> (n_columns, column_names, values);
			map[key] = val;
			return 0;
		});
		return map;
	}


	public Gee.Map<K, V> fetch_value_map<K, V> (Query query) {
		var map = new Gee.HashMap<K, V> ();
		engine.exec_sql (query.sql (), (n_columns, values, column_names) => {
			var key_value = Value (typeof (K));
			assemble_value (ref key_value, values[0]);
			var key = wrap_value<K> (ref key_value);

			var val_value = Value (typeof (V));
			assemble_value (ref val_value, values[1]);
			var val = wrap_value<V> (ref val_value);

			map[key] = val;
			return 0;
		});
		return map;
	}


	public string? fetch_string (Query query, string? def) {
		return fetch_value<string?> (query, def);
	}


	public int query_count (string from, string where) {
		var q = new Query.select ("COUNT(*)");
		q.from (from);
		q.where (where);
		return fetch_value<int> (q, 0);
	}


	/**
	 * One of most important functions in DB library.
	 * What does it do?
	 *     - if value is null, leaves property untouched;
	 *     - if property is an Entity, tries to fetch this entity from the database;
	 *     - if property is string, copies it;
	 *     - if property is something else, tries to convert it via g_value_transform.
	 */
	private void prepare_entity (Entity ent, int n_fields,
			[CCode (array_length = false)] string[] fields,
			[CCode (array_length = false)] string[] values) {
		var type = ent.get_type ();
		var obj_class = (ObjectClass) type.class_ref ();

		for (var i = 0; i < n_fields; i++) {
			unowned string? val = values[i];
			unowned string prop_name = fields[i];
			var prop = obj_class.find_property (prop_name);
			if (prop == null)
				error ("Could not find propery '%s.%s'", type.name (), prop_name);
			var prop_type = prop.value_type;

			var dest_val = Value (prop_type);
			if (!assemble_value (ref dest_val, val))
				warning ("Could not convert value '%s' from 'string' to '%s' for property '%s.%s'\n",
						val, prop_type.name (), type.name (), prop_name);

			ent.set_property (prop_name, dest_val);
		}
	}


	private bool assemble_value (ref Value val, string? str) {
		var type = val.type ();

		/* Entity */
		if (type.is_a (typeof (Entity))) {
			Entity? entity = null;
			if (str != null) {
				var entity_id = int.parse (str);
				if (entity_id > 0)
					entity = fetch_simple_entity_full (type, entity_id);
			}
			val.set_object (entity);
			return true;
		}

		/* String */
		if (type == typeof (string)) {
			val.set_string (str);
			return true;
		}

		/* Integer */
		if (type == typeof (int)) {
			if (str != null)
				val.set_int (int.parse (str));
			return true;
		}

		/* Integer 64 */
		if (type == typeof (int64)) {
			if (str != null)
				val.set_int64 (int64.parse (str));
			return true;
		}

		/* Boolean */
		if (type == typeof (bool)) {
			if (str != null)
				val.set_boolean (int.parse (str) > 0);
			return true;
		}

		/* Double */
		if (type == typeof (double)) {
			if (str != null)
				val.set_double (double.parse (str));
			return true;
		}

		/* Adapter */
		if (value_adapter.convert_from (null, null, str, ref val))
			return true;

		/* GLib transformer */
		if (str != null) {
			var tmp = Value (typeof (string));
			tmp.set_string (str);
			if (tmp.transform (ref val))
				return true;
		}

		val.unset ();
		return false;
	}


	public Entity make_entity_full (Type type, int n_fields,
			[CCode (array_length = false)] string[] fields,
			[CCode (array_length = false)] string[] values) {
		var ent = Object.new (type, "db", this) as Entity;
		prepare_entity (ent, n_fields, fields, values);
		return ent;
	}


	public T make_entity<T> (int n_fields,
			[CCode (array_length = false)] string[] fields,
			[CCode (array_length = false)] string[] values) {
		return make_entity_full (typeof (T), n_fields, fields, values);
	}


	/*
		Deleteion
	*/
	public void delete_entity (Entity entity) {
		var query = new Query.delete (entity.db_table ());

		if (entity is SimpleEntity) {
			query.where ("id = %d".printf (((SimpleEntity) entity).id));
		} else {
			/* TODO: composite key */
		}

		exec (query);
	}


	/*
	 * This function uses GLib Value transformator. This may not be enough.
	 * As an option we can convert a Value to some sort of adapter type.
	 * Or we can have internal converter.
	 */
	private string? prepare_value (ref Value val, string prop_name) {
		var type = val.type ();

		if (val.type ().is_a (typeof (Entity))) {
			var obj = val.get_object () as Entity;
			if (obj == null)
				return "NULL";
			val = Value (typeof (int));
			obj.get_property ("id", ref val);
		} else if (type == typeof (bool)) {
			if (val.get_boolean () == true)
				return "1";
			return "0";
		} else if (type == typeof (double)) {
			var d = val.get_double ();
			char[] buf = new char[double.DTOSTR_BUF_SIZE];
			return d.to_str (buf);
		} else if (type == typeof (float)) {
			var d = (double) val.get_float ();
			char[] buf = new char[double.DTOSTR_BUF_SIZE];
			return d.to_str (buf);
		} else if (type == typeof (string)) {
			unowned string s = val.get_string ();
			if (s == null)
				return "NULL";
			else
				return "'%s'".printf (engine.escape_string (s));
		}

		string? s = null;
		if (value_adapter.convert_to (null, prop_name, ref val, out s)) {
			if (s == null)
				s = "NULL";
		} else {
			/* try to convert to a string using GLib Value transformator */
			var str_val = Value (typeof (string));
			if (val.transform (ref str_val))
				s = str_val.get_string ();
		}
		return s;
	}


	private void prepare_value_list (StringBuilder sb, Entity entity, string[] props, ObjectClass obj_class) {
		foreach (unowned string prop_name in props) {
			unowned ParamSpec? prop_spec = obj_class.find_property (prop_name);
			var val = Value (prop_spec.value_type);
			entity.get_property (prop_name, ref val);

			var s = prepare_value (ref val, prop_name);
			if (s == null) {
				warning ("Couldn't prepare the value of property '%s.%s' of type '%s' for using in SQL query",
						entity.get_type ().name (), prop_name, val.type ().name ());
				s = "NULL";
			}
			sb.append (s).append (", ");
		}
	}


	private void prepare_column_value_list (StringBuilder sb, Entity entity, string[] props, ObjectClass obj_class) {
		foreach (unowned string prop_name in props) {
			unowned ParamSpec? prop_spec = obj_class.find_property (prop_name);
			var val = Value (prop_spec.value_type);
			entity.get_property (prop_name, ref val);

			var s = prepare_value (ref val, prop_name);
			if (s == null) {
				warning ("Couldn't prepare the value of property '%s.%s' of type '%s' for using in SQL query",
						entity.get_type ().name (), prop_name, val.type ().name ());
				s = "NULL";
			}

			sb.append_printf ("%s=%s, ", prop_name, s);
		}
	}


	private void persist_auto_key (Entity entity, string[] fields, ObjectClass obj_class) {
		var id_val = Value (typeof (int));
		entity.get_property ("id", ref id_val);
		var entity_id = id_val.get_int ();

		if (entity_id == 0) {
			var sb = new StringBuilder.sized (64);
			prepare_value_list (sb, entity, fields, obj_class);
			sb.truncate (sb.len - 2);

			engine.exec_sql ("INSERT INTO %s VALUES (NULL, %s)".printf (entity.db_table (), sb.str));
			entity.set_property ("id", (int) engine.last_insert_rowid ());
		} else {
			var sb = new StringBuilder.sized (64);
			prepare_column_value_list (sb, entity, fields, obj_class);
			sb.truncate (sb.len - 2);

			engine.exec_sql ("UPDATE %s SET %s WHERE id=%d"
					.printf (entity.db_table (), sb.str, entity_id));
		}
	}


	private void persist_composite_key (Entity entity, string[] keys, string[] fields, ObjectClass obj_class) {
		var sb = new StringBuilder.sized (64);
		prepare_value_list (sb, entity, keys, obj_class);
		prepare_value_list (sb, entity, fields, obj_class);
		sb.truncate (sb.len - 2);

		engine.exec_sql ("REPLACE INTO %s VALUES (%s)".printf (entity.db_table (), sb.str));
	}


	public void persist (Entity entity) {
		unowned ObjectClass obj_class = (ObjectClass) entity.get_type ().class_peek ();
		unowned string[] keys = entity.db_keys ();
		unowned string[] fields = entity.db_fields ();

		if (keys.length == 1 && keys[0] == "id")
			persist_auto_key (entity, fields, obj_class);
		else
			persist_composite_key (entity, keys, fields, obj_class);
	}



	/*
	 *	Transaction control.
	 */
	public void begin_transaction () {
		engine.exec_sql ("BEGIN TRANSACTION");
	}


	public void commit_transaction () {
		engine.exec_sql ("COMMIT TRANSACTION");
	}


	public void rollback_transaction () {
		engine.exec_sql ("ROLLBACK TRANSACTION");
	}
}


}

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
		var data = resources_lookup_data ("/data/init.sql", ResourceLookupFlags.NONE).get_data ();
		exec_sql ((string) data);
	}


	private void exec_sql (string sql, Sqlite.Callback? callback = null) throws DatabaseError {
		string errmsg;
		stdout.printf ("%s\n", sql);
		if (db.exec (sql, callback, out errmsg) != Sqlite.OK)
			throw new DatabaseError.EXEC_FAILED ("Error executing SQL statement: %s\n", errmsg);
	}


	public Gee.List<Entity> get_account_list () throws DatabaseError {
		return get_entity_list ("SELECT * FROM account", typeof (Account));
	}


	public Gee.List<Entity> get_people_list (Period period, Account account) throws DatabaseError {
		return get_entity_list ("SELECT * FROM people", typeof (Person));
	}


	public Gee.List<Entity> get_tax_list (Period period, Account account) throws DatabaseError {
		return get_entity_list ("SELECT * FROM taxes", typeof (Tax));
	}


	private Gee.List<Entity> get_entity_list (string sql, Type type) throws DatabaseError {
		var obj_class = (ObjectClass) type.class_ref ();
		var list = new Gee.ArrayList<Entity> ();
//		var str_val = Value (typeof (string));

		exec_sql (sql, (n_columns, values, column_names) => {
			var entity = Object.new (type) as Entity;
			for (var i = 0; i < n_columns; i++) {
				var prop = obj_class.find_property (column_names[i]);
				var dst_val = Value (prop.value_type);

/* FIXME: waht's wrong with transformation
				str_val.set_string (values[i]);

				var prop = obj_class.find_property (column_names[i]);
				var dst_val = Value (prop.value_type);
				if (str_val.transform (ref dst_val) == false)
					stdout.printf ("Couldnt transform from '%s' to '%s'\n",
							str_val.type ().name (),
							dst_val.type ().name ());
				entity.set_property (column_names[i], dst_val);
*/

				Type prop_type = prop.value_type;
				if (prop_type == typeof (string))
					dst_val.set_string (values[i]);
				else if (prop_type == typeof (int64))
					dst_val.set_int64 (int64.parse (values[i]));
				entity.set_property (column_names[i], dst_val);
			}
			list.add (entity);
			return 0;
		});

		return list;
	}


	private void persist_auto_key (Entity entity, string[] fields, ObjectClass obj_class) {
		var id_val = Value (typeof (int64));
		entity.get_property ("id", ref id_val);
		var entity_id = id_val.get_int64 ();

		if (entity_id == 0) {
			string values = "";
			foreach (var field_name in fields) {
				var prop_spec = obj_class.find_property (field_name);
				var val = Value (prop_spec.value_type);
				entity.get_property (field_name, ref val);

				if (val.type () == typeof (float))
					values += ", %f".printf (val.get_float ());
				else
					values += ", '%s'".printf (val.get_string ());
			}

			var query = "INSERT INTO `%s` VALUES (NULL%s)".printf (entity.table_name, values);
			exec_sql (query);
			entity_id = db.last_insert_rowid ();
			entity.set_property ("id", id_val);
		} else {
			string values = "";
			foreach (var field_name in fields) {
				var prop_spec = obj_class.find_property (field_name);
				var val = Value (prop_spec.value_type);
				entity.get_property (field_name, ref val);

				if (val.type () == typeof (float))
					values += "`%s`=%f, ".printf (field_name, val.get_float ());
				else
					values += "`%s`='%s', ".printf (field_name, val.get_string ());
			}
			values = values[0:-2];

			var query = "UPDATE `%s` SET %s WHERE `id`=%lld".printf (entity.table_name, values, entity_id);
			exec_sql (query);
		}
	}


	private void persist_composite_key (Entity entity, string[] keys, string[] fields, ObjectClass obj_class) {
	}


	public void persist (Entity entity) throws Error {
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

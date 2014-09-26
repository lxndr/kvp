/* db.vapi generated by valac 0.26.0, do not modify. */

namespace DB {
	[CCode (cheader_filename = "db.h")]
	public abstract class Entity : GLib.Object {
		public Entity ();
		public abstract unowned string[] db_fields ();
		public abstract unowned string[] db_keys ();
		public abstract unowned string db_table ();
		public void persist ();
		public abstract void remove ();
		public DB.Database db { get; set construct; }
	}
	[CCode (cheader_filename = "db.h")]
	public class SQLiteDatabase : GLib.Object, DB.Database {
		public SQLiteDatabase (string _path);
		public string path { get; set construct; }
	}
	[CCode (cheader_filename = "db.h")]
	public abstract class SimpleEntity : DB.Entity {
		public SimpleEntity ();
		public override unowned string[] db_keys ();
		public override void remove ();
		public int64 id { get; set; }
	}
	[CCode (cheader_filename = "db.h")]
	public interface Database : GLib.Object {
		public string build_select_query (string table, string? columns = null, string? where = null, string? order_by = null, int limit = -1, string? extra = null);
		public void delete_entity (string table, string where);
		public abstract void exec_sql (string sql, Sqlite.Callback? callback = null);
		public T fetch_entity<T> (string? table, string where, bool recursive = true);
		public T fetch_entity_by_id<T> (int64 id, string? table = null, bool recursive = true);
		public Gee.List<T> fetch_entity_list<T> (string table, string? where = null, string? order_by = null, int limit = -1, bool recursive = true);
		public Gee.List<DB.Entity> fetch_entity_list_full (GLib.Type type, string? table = null, string? where = null, string? order_by = null, int limit = -1, bool recursive = true);
		public int fetch_int (string table, string column, string? where = null);
		public int64 fetch_int64 (string table, string column, string? where = null);
		public Gee.Map<int,T> fetch_int_entity_map<T> (string table, string key_field, string? where = null);
		public string? fetch_string (string table, string column, string? where = null);
		public abstract int64 last_insert_rowid ();
		public T make_entity<T> (int n_fields, [CCode (array_length = false)] string[] fields, [CCode (array_length = false)] string[] values, bool recursive = true);
		public DB.Entity make_entity_full (GLib.Type type, int n_fields, [CCode (array_length = false)] string[] fields, [CCode (array_length = false)] string[] values, bool recursive = true);
		public void persist (DB.Entity entity);
		public int64 query_count (string table, string? where);
		public int64 query_sum (string table, string column, string where);
	}
}

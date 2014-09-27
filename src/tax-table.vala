namespace Kv {


public class TaxTable : DB.ViewTable {
	private int period;
	private Account? account;

	private int strikethrough_model_column;
	private int foreground_model_column;


	public TaxTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Tax),
				view_only: true);
	}


	public void setup (Account? _account, int _period) {
		period = _period;
		account = _account;

		update_view ();
	}


	protected override unowned string[] view_properties () {
		const string props[] = {
			N_("apply"),
			N_("service_name"),
			N_("amount"),
			N_("price"),
			N_("total")
		};
		return props;
	}


	protected override Gtk.Menu? create_menu (bool add_remove = true) {
		return null;
	}


	protected override void create_list_store (Gee.List<Type> types, Gee.List<unowned ParamSpec> props) {
		base.create_list_store (types, props);

		foreground_model_column = types.size;
		types.add (typeof (string));
		strikethrough_model_column = foreground_model_column + 1;
		types.add (typeof (bool));
	}


	protected override void create_list_column (Gtk.TreeViewColumn column, out Gtk.CellRenderer cell,
			ParamSpec prop, int model_column) {
		base.create_list_column (column, out cell, prop, model_column);

stdout.printf (">> %s\n", prop.value_type.name ());

		if (prop.value_type == typeof (Money))
			cell.set ("xalign", 1.0f);
		if (cell is Gtk.CellRendererText)
			column.add_attribute (cell, "foreground", foreground_model_column);
		if (prop.name == "service-name")
			column.add_attribute (cell, "strikethrough", strikethrough_model_column);
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (account == null)
			return new Gee.ArrayList<DB.Entity> ();
		return (db as Database).get_tax_list (account, period);
	}


	public override void row_edited (DB.Entity entity, string prop_name) {
		var tax = entity as Tax;

		if (prop_name == "apply") {
			unowned string? color = null;
			var apply = tax.apply;
			if (apply == false)
				color = "grey";

			Gtk.TreeIter iter;
			find_row (out iter, entity);
			list_store.set (iter,
					foreground_model_column, color,
					strikethrough_model_column, !apply);
		}
	}
}


}

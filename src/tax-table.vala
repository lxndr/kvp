namespace Kv {


public class TaxTable : DB.ViewTable {
	private AccountPeriod? current_periodic;

	private int strikethrough_model_column;
	private int foreground_model_column;
	private int editable_model_column;
	private int visible_model_column;


	public signal void total_changed (Tax tax);


	public TaxTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Tax));
	}


	public void setup (AccountPeriod? periodic) {
		current_periodic = periodic;
		refresh_view ();
	}


	protected override unowned string[] viewable_props () {
		const string[] props = {
			N_("apply"),
			N_("service-name"),
			N_("amount"),
			N_("price-value"),
			N_("total")
		};
		return props;
	}


	protected override Gtk.Menu? create_menu (bool add_remove = true) {
		return null;
	}


	protected override void create_list_store (Gee.List<Type> types, Gee.List<unowned ParamSpec> props) {
		base.create_list_store (types, props);

		var last_model_column = types.size;
		foreground_model_column = last_model_column++;
		types.add (typeof (string));
		strikethrough_model_column = last_model_column++;
		types.add (typeof (bool));
		editable_model_column = last_model_column++;
		types.add (typeof (bool));
		visible_model_column = last_model_column++;
		types.add (typeof (bool));
	}


	protected override void create_list_column (Gtk.TreeViewColumn column, out Gtk.CellRenderer cell,
			ParamSpec prop, int model_column) {
		base.create_list_column (column, out cell, prop, model_column);

		if (prop.value_type == typeof (Money))
			cell.set ("xalign", 1.0f);
		if (cell is Gtk.CellRendererText)
			column.add_attribute (cell, "foreground", foreground_model_column);
		if (prop.name == "service-name")
			column.add_attribute (cell, "strikethrough", strikethrough_model_column);
		if (prop.name == "amount")
			column.add_attribute (cell, "editable", editable_model_column);
		if (prop.name == "amount" || prop.name == "price-value")
			column.add_attribute (cell, "visible", visible_model_column);
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (current_periodic == null)
			return new Gee.ArrayList<DB.Entity> ();
		return (db as Database).get_tax_list (current_periodic);
	}


	protected override void row_refreshed (Gtk.TreeIter tree_iter, DB.Entity entity) {
		unowned Tax tax = entity as Tax;

		unowned string? color = null;
		var apply = tax.apply;
		if (apply == false)
			color = "grey";

		list_store.set (tree_iter,
				foreground_model_column, color,
				strikethrough_model_column, !apply,
				visible_model_column, tax.price.method != null);
	}


	public override void row_edited (Gtk.TreeIter tree_iter, DB.Entity entity, string prop_name) {
		unowned Tax tax = (Tax) entity;

		switch (prop_name) {
		case "apply":
			tax.calc_amount ();
			tax.calc_total ();
			break;
		case "amount":
			tax.calc_total ();
			break;
		}

		total_changed (tax);

		/* persiste AFTER calculations */
		base.row_edited (tree_iter, entity, prop_name);
	}
}


}

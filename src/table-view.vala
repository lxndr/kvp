namespace Kv {


public abstract class TableView {
	protected Database db;
	private Type object_type;

	private Gtk.ScrolledWindow root_widget;
	protected Gtk.TreeView list_view;
	protected Gtk.ListStore list_store;
	protected Gtk.Menu popup_menu;
	private Gtk.MenuItem remove_menu_item;

	protected abstract Gee.List<Entity> get_entity_list ();


	public TableView (Database dbase, Type type) {
		db = dbase;
		object_type = type;

		Gtk.MenuItem menu_item;

		/* popup menu */
		popup_menu = new Gtk.Menu ();

		menu_item = new Gtk.MenuItem.with_label ("Add");
		menu_item.activate.connect (add_item_clicked);
		popup_menu.add (menu_item);

		remove_menu_item = new Gtk.MenuItem.with_label ("Remove");
		menu_item.activate.connect (remove_item_clicked);
		popup_menu.add (remove_menu_item);

		menu_item = new Gtk.SeparatorMenuItem ();
		popup_menu.add (menu_item);

		popup_menu.show_all ();

		/* list store */
		Type[] types = {};
		types += typeof (Object);

		var tmp = Object.new (object_type) as Entity;
		var props = tmp.get_view_properties ();
		foreach (var prop_name in props)
			types += typeof (string);

		list_store = new Gtk.ListStore.newv (types);

		/* list view */
		root_widget = new Gtk.ScrolledWindow (null, null);
		root_widget.shadow_type = Gtk.ShadowType.IN;

		list_view = new Gtk.TreeView.with_model (list_store);
		create_list_columns (props);
		list_view.button_release_event.connect (button_released);
		root_widget.add (list_view);

		root_widget.show_all ();
	}


	public Gtk.Widget get_root_widget () {
		return root_widget;
	}


	private void create_list_columns (string[] props) {
		Gtk.CellRendererText cell;
		Gtk.TreeViewColumn column;

		for (var i = 0; i < props.length; i++) {
			var prop = props[i];

			cell = new Gtk.CellRendererText ();
			cell.set_data<string> ("property_name", prop);
			cell.set_data<int> ("property_column", i + 1);
			cell.editable = true;
			cell.edited.connect (row_edited);

			column = new Gtk.TreeViewColumn.with_attributes (
					prop, cell,
					"text", i + 1);
			list_view.insert_column (column, -1);
		}
	}


	private bool button_released (Gdk.EventButton event) {
		if (event.button == 3) {
			remove_menu_item.sensitive = list_view.get_selection ().count_selected_rows () > 0;
			popup_menu.popup (null, null, null, event.button, Gtk.get_current_event_time ());
		}

		return false;
	}


	private void row_edited (Gtk.CellRendererText cell, string _path, string new_text) {
		Entity entity;
		Gtk.TreeIter iter;

		var path = new Gtk.TreePath.from_string (_path);
		list_store.get_iter (out iter, path);
		list_store.get (iter, 0, out entity);

		var property_name = cell.get_data<string> ("property_name");
		var property_column = cell.get_data<int> ("property_column");

		var val = Value (typeof (string));
		val.set_string (new_text);

		entity.set_property (property_name, val);
		list_store.set_value (iter, property_column, val);

//		entity.persist ();
	}


	public void add_item_clicked () {
		var entity = Object.new (object_type) as Entity;

		Gtk.TreeIter iter;
		list_store.append (out iter);
		list_store.set (iter, 0, entity);

		var obj_class = (ObjectClass) object_type.class_ref ();
		var properties = obj_class.list_properties ();
		for (var i = 0; i < properties.length; i++) {
			var prop = properties[i];
			var val = Value (typeof (string));
			entity.get_property (prop.name, ref val);
			list_store.set_value (iter, i + 1, val);
		}

		/* TODO persists object */
	}


	public void remove_item_clicked () {
		Gtk.TreeIter iter;
		if (list_view.get_selection ().get_selected (null, out iter) == false)
			return;

		Entity obj;
		list_store.get (iter, 0, out obj);

		var msg = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL,
				Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO,
				"Are you sure you want to delete '%s' and all its data?",
				obj.get_display_name ());
		msg.response.connect ((response_id) => {
			if (response_id == Gtk.ResponseType.YES) {
//				update_account_list ();
//				update_people_list ();
//				update_tax_list ();
			}
		});
		msg.show ();

		/* TODO persist object */
	}


	public void update_view () {
		list_store.clear ();
		var list = get_entity_list ();

		foreach (var entity in list) {
			var properties = entity.get_view_properties ();

			Gtk.TreeIter iter;
			list_store.append (out iter);

			for (var i = 0; i < properties.length; i++) {
				var property_name = properties[i];
				var val = Value (typeof (string));
				entity.get_property (property_name, ref val);
				list_store.set_value (iter, i + 1, val);
			}
		}
	}
}


}

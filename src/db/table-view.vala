namespace DB {


public class PropertyAdapter : Object {
	public string val;

	public PropertyAdapter (string _val) {
		val = _val;
	}
}



public abstract class TableView {
	protected Database db;
	private Type object_type;
	public Entity? selected_entity;

	private Gtk.ScrolledWindow root_widget;
	protected Gtk.TreeView list_view;
	protected Gtk.ListStore list_store;
	protected Gtk.Menu popup_menu;
	private Gtk.MenuItem remove_menu_item;


	protected abstract unowned string[] view_properties ();
	protected abstract Gee.List<Entity> get_entity_list ();


	public signal void selection_changed ();
	public virtual signal void row_edited (Entity entity, string prop_name) {}


	protected virtual Entity new_entity () {
		return Object.new (object_type) as Entity;
	}


	protected virtual void remove_entity (Entity entity) {
		entity.remove ();
	}


	public Entity? get_selected_entity () {
		return selected_entity;
	}


	public TableView (Database dbase, Type type) {
		db = dbase;
		object_type = type;
		selected_entity = null;

		Gtk.MenuItem menu_item;

		/* popup menu */
		popup_menu = new Gtk.Menu ();

		menu_item = new Gtk.MenuItem.with_label ("Add");
		menu_item.activate.connect (add_item_clicked);
		popup_menu.add (menu_item);

		remove_menu_item = new Gtk.MenuItem.with_label ("Remove");
		remove_menu_item.activate.connect (remove_item_clicked);
		popup_menu.add (remove_menu_item);

		menu_item = new Gtk.SeparatorMenuItem ();
		popup_menu.add (menu_item);

		popup_menu.show_all ();

		/* list store */
		Type[] types = {};
		types += typeof (Object);

		var obj_class = (ObjectClass) object_type.class_ref ();
		var props = view_properties ();
		foreach (var prop_name in props) {
			var prop_spec = obj_class.find_property (prop_name);
			if (prop_spec.value_type == typeof (bool))
				types += typeof (bool);
			else
				types += typeof (string);
		}

		list_store = new Gtk.ListStore.newv (types);

		/* list view */
		root_widget = new Gtk.ScrolledWindow (null, null);
		root_widget.shadow_type = Gtk.ShadowType.IN;

		list_view = new Gtk.TreeView.with_model (list_store);
		list_view.get_selection ().changed.connect (list_selection_changed);
		create_list_columns (props);
		list_view.button_release_event.connect (button_released);
		root_widget.add (list_view);

		root_widget.show_all ();
	}


	public Gtk.Widget get_root_widget () {
		return root_widget;
	}


	private void create_list_columns (string[] props) {
		var obj_class = (ObjectClass) object_type.class_ref ();
		Gtk.TreeViewColumn column;

		for (var i = 0; i < props.length; i++) {
			Gtk.CellRenderer cell;
			var prop_name = props[i];
			var prop_spec = obj_class.find_property (prop_name);
			var prop_type = prop_spec.value_type;

			if (prop_type == typeof (string) ||
					prop_type == typeof (int) ||
					prop_type == typeof (double) ||
					prop_type.is_a (Type.BOXED)) {
				cell = new Gtk.CellRendererText ();
				cell.set ("editable", (prop_spec.flags & ParamFlags.WRITABLE) > 0);
				/* FIXME: could use Object.connect */
				(cell as Gtk.CellRendererText).edited.connect (text_row_edited);
			} else if (prop_type == typeof (bool)) {
				cell = new Gtk.CellRendererToggle ();
				(cell as Gtk.CellRendererToggle).toggled.connect (cell_toggled);
			} else if (prop_type.is_a (typeof (Entity))) {
				var combo_store = new Gtk.ListStore (2, typeof (string), typeof (Entity));
				var entity_list = db.fetch_entity_list_full (prop_type) as Gee.List<Viewable>;

				foreach (var entity in entity_list) {
					Gtk.TreeIter iter;
					combo_store.append (out iter);
					combo_store.set (iter, 0, entity.display_name, 1, entity);
				}

				cell = new Gtk.CellRendererCombo ();
				cell.set ("editable", true);
				cell.set ("has-entry", false);
				cell.set ("model", combo_store);
				cell.set ("text-column", 0);
				(cell as Gtk.CellRendererCombo).changed.connect (combo_row_changed);
			} else {
				error ("Unsupported property type '%s' for table column '%s'",
						prop_spec.value_type.name (), prop_name);
			}

			cell.set_data<string> ("property_name", prop_name);
			cell.set_data<int> ("property_column", i + 1);

			if (prop_type == typeof (bool)) {
				column = new Gtk.TreeViewColumn.with_attributes (
						dgettext (null, prop_name), cell,
						"active", i + 1);
			} else {
				column = new Gtk.TreeViewColumn.with_attributes (
						dgettext (null, prop_name), cell,
						"text", i + 1);
			}

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


	private void list_selection_changed (Gtk.TreeSelection selection) {
		Gtk.TreeIter iter;
		if (selection.get_selected (null, out iter))
			list_store.get (iter, 0, out selected_entity);
		else
			selected_entity = null;

		selection_changed ();
	}


	private void text_row_edited (Gtk.CellRendererText cell, string _path,
			string new_text) {
		Entity entity;
		Gtk.TreeIter iter;

		var path = new Gtk.TreePath.from_string (_path);
		list_store.get_iter (out iter, path);
		list_store.get (iter, 0, out entity);

		var property_name = cell.get_data<string> ("property_name");
//		var property_column = cell.get_data<int> ("property_column");

		var obj_class = (ObjectClass) entity.get_type ().class_ref ();
		var prop_spec = obj_class.find_property (property_name);
		var prop_type = prop_spec.value_type;

		if (prop_type == typeof (int) || prop_type == typeof (string)) {
			var val = Value (typeof (string));
			val.set_string (new_text);
			entity.set_property (property_name, val);
			// list_store.set_value (iter, property_column, val);
		} else {
			var ad_val = Value (typeof (PropertyAdapter));
			ad_val.set_object (new PropertyAdapter (new_text));

			/* transform string to property value */
			var val = Value (prop_type);
			if (ad_val.transform (ref val) == false)
				warning ("Could not transform %s to %s",
						ad_val.type ().name (), val.type ().name ());
			entity.set_property (property_name, val);

			/* quick and dirty */
			// list_store.set_value (iter, property_column, val);
		}

		update_row (iter, entity);
		db.persist (entity);
		row_edited (entity, property_name);
	}


	private void cell_toggled (Gtk.CellRendererToggle cell, string _path) {
		Entity entity;
		Gtk.TreeIter iter;		var path = new Gtk.TreePath.from_string (_path);
		list_store.get_iter (out iter, path);
		list_store.get (iter, 0, out entity);

		var property_name = cell.get_data<string> ("property_name");

		var val = Value (typeof (bool));
		entity.get_property (property_name, ref val);
		val.set_boolean (!val.get_boolean ());
		entity.set_property (property_name, val);

		update_row (iter, entity);
		entity.persist ();
		row_edited (entity, property_name);
	}


	private void combo_row_changed (Gtk.CellRendererCombo cell, string _path,
			Gtk.TreeIter prop_iter) {
		Entity entity;
		Gtk.TreeIter iter;
		var path = new Gtk.TreePath.from_string (_path);
		list_store.get_iter (out iter, path);
		list_store.get (iter, 0, out entity);

		Entity prop_entity;
		cell.model.get (prop_iter, 1, out prop_entity);

		var property_name = cell.get_data<string> ("property_name");
		var property_column = cell.get_data<int> ("property_column");

		entity.set_property (property_name, prop_entity);

		var val = Value (typeof (string));
		val.set_string ((prop_entity as Viewable).display_name);
		list_store.set_value (iter, property_column, val);

		db.persist (entity);
	}


	public void add_item_clicked () {
		var entity = new_entity ();

		Gtk.TreeIter iter;
		list_store.append (out iter);
		update_row (iter, entity);

		db.persist (entity);
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
				(obj as Viewable).display_name);
		msg.response.connect ((response_id) => {
			if (response_id == Gtk.ResponseType.YES) {
				remove_entity (obj);
				list_store.remove (iter);
			}

			msg.destroy ();
		});
		msg.show ();
	}


	public void update_view () {
		Gtk.TreeIter iter;
		list_store.clear ();
		var list = get_entity_list ();

		foreach (var entity in list) {
			list_store.append (out iter);
			update_row (iter, entity);
		}

		if (list_store.get_iter_first (out iter) == true)
			list_view.get_selection ().select_iter (iter);
	}


	private void update_row (Gtk.TreeIter iter, Entity entity) {
		var obj_class = (ObjectClass) entity.get_type ().class_ref ();
		var props = view_properties ();
		list_store.set (iter, 0, entity);

		for (var i = 0; i < props.length; i++) {
			var prop_name = props[i];
			var prop_spec = obj_class.find_property (prop_name);
			var val = Value (prop_spec.value_type);
			entity.get_property (prop_name, ref val);

			if (val.type () == typeof (string) || val.type () == typeof (int) ||
					val.type () == typeof (bool)) {
				/* these convert nicely */
				list_store.set_value (iter, i + 1, val);
			} else if (val.type ().is_a (typeof (Entity))) {
				/* entity, a special case */
				var obj = val.get_object () as Viewable;
				if (obj != null)
					list_store.set (iter, i + 1, obj.display_name);
			} else {
				/* first, try usng an adaptor */
				var ad_val = Value (typeof (PropertyAdapter));
				if (val.transform (ref ad_val) == true) {
					val.unset ();
					val.init (typeof (string));
					val.set_string ((ad_val.get_object () as PropertyAdapter).val);
				} else {
					warning ("Could not transform %s to %s",
							val.type ().name (), ad_val.type ().name ());
				}

				list_store.set_value (iter, i + 1, val);
			}
		}
	}


	private bool find_row (out Gtk.TreeIter iter, DB.Entity entity) {
		if (list_store.get_iter_first (out iter) == true) {
			do {
				DB.Entity ent;
				list_store.get (iter, 0, out ent);
				if (ent == entity)
					return true;
			} while (list_store.iter_next (ref iter) == true);
		}

		return false;
	}


	public void refresh_row (DB.Entity entity) {
		Gtk.TreeIter iter;
		if (find_row (out iter, entity) == true)
			update_row (iter, entity);
	}
}


}

namespace DB {


[Compact]
public struct PropertyAdapter {
	public string? val;
}



public abstract class ViewTable : Gtk.TreeView {
	public Database db { get; construct set; }
	public Type object_type { get; construct set; }

	private bool _read_only;
	public bool read_only {
		get { return _read_only; }
		set { _set_read_only (value); }
		default = false;
	}
	

	public Entity? selected_entity;

	protected Gtk.ListStore list_store;
	protected Gtk.Menu? menu;
	private Gtk.MenuItem? remove_menu_item;


	protected abstract unowned string[] viewable_props ();
	protected abstract Gee.List<Entity> get_entity_list ();


	public signal void selection_changed ();
	public virtual signal void row_refreshed (Gtk.TreeIter tree_iter, Entity entity) {}


	public virtual signal void row_edited (Gtk.TreeIter tree_iter, Entity entity, string prop_name) {
		entity.persist ();
	}


	protected virtual Entity? new_entity () {
		return Object.new (object_type, db: this.db) as Entity;
	}


	protected virtual void remove_entity (Entity entity) {
		entity.remove ();
	}


	public unowned Entity? get_selected_entity () {
		return selected_entity;
	}


	construct {
		/* check if we are working with Entity object */
		if (object_type.is_a (typeof (Entity)) == false)
			error ("Object type '%s' is not Entity object", object_type.name ());

		/* popup menu */
		menu = create_menu (true);

		/* properties */
		var obj_class = (ObjectClass) object_type.class_ref ();
		var props = new Gee.ArrayList<unowned ParamSpec> ();
		foreach (unowned string prop_name in viewable_props ()) {
			unowned ParamSpec? spec = obj_class.find_property (prop_name);
			if (spec == null) {
				warning ("Couldn't find property '%s' in '%s'", prop_name, object_type.name ());
				continue;
			}

			props.add (spec);
		}

		/* list store */
		var types = new Gee.ArrayList<Type> ();
		types.add (typeof (Entity));
		create_list_store (types, props);
		list_store = new Gtk.ListStore.newv (types.to_array ());

		/* columns */
		create_list_columns (props);

		/* list view */
		this.model = list_store;
		this.enable_grid_lines = Gtk.TreeViewGridLines.VERTICAL;
		this.headers_clickable = true;
		this.get_selection ().changed.connect (list_selection_changed);
		this.button_release_event.connect (button_released);
	}


	protected virtual Gtk.Menu? create_menu (bool add_remove = true) {
		menu = new Gtk.Menu ();

		if (add_remove == true) {
			Gtk.MenuItem menu_item;

			menu_item = new Gtk.MenuItem.with_label (_("Add"));
			menu_item.activate.connect (add_item_clicked);
			menu.add (menu_item);

			remove_menu_item = new Gtk.MenuItem.with_label (_("Remove"));
			remove_menu_item.activate.connect (remove_item_clicked);
			menu.add (remove_menu_item);

			menu.show_all ();
		}

		return menu;
	}


	protected virtual void create_list_store (Gee.List<Type> types, Gee.List<unowned ParamSpec> props) {
		foreach (unowned ParamSpec prop in props) {
			var prop_type = prop.value_type;
			if (prop_type == typeof (bool))
				types.add (typeof (bool));
			else
				types.add (typeof (string));
		}
	}


	protected virtual void create_list_column (Gtk.TreeViewColumn column, out Gtk.CellRenderer cell,
			ParamSpec prop, int model_column) {
		var prop_type = prop.value_type;

		if (prop_type.is_a (typeof (Entity))) {
			var combo_store = new Gtk.ListStore (2, typeof (string), typeof (Entity));
			var entity_list = db.fetch_entity_list_full (prop_type,
					Query.entity_list (db, prop_type)) as Gee.List<Viewable>;

			foreach (var entity in entity_list) {
				Gtk.TreeIter iter;
				combo_store.append (out iter);
				combo_store.set (iter, 0, entity.display_name, 1, entity);
			}

			var combo_cell = new Gtk.CellRendererCombo ();
			combo_cell.set ("editable", true,
							"has-entry", false,
							"model", combo_store,
							"text-column", 0);
			combo_cell.changed.connect (combo_cell_changed);
			column.pack_start (combo_cell, true);
			column.add_attribute (combo_cell, "text", model_column);
			cell = combo_cell;
		} else if (prop_type == typeof (bool)) {
			var toggle_cell = new Gtk.CellRendererToggle ();
			toggle_cell.toggled.connect (toggle_cell_toggled);
			column.pack_start (toggle_cell, false);
			column.add_attribute (toggle_cell, "active", model_column);
			cell = toggle_cell;
		} else {
			var text_cell = new Gtk.CellRendererText ();
			text_cell.set ("editable", (prop.flags & ParamFlags.WRITABLE) > 0);
			text_cell.edited.connect (text_cell_edited);
			column.pack_start (text_cell, true);
			column.add_attribute (text_cell, "text", model_column);
			cell = text_cell;
		}

		cell.set_data<string> ("property_name", prop.name);
		cell.set_data<int> ("property_column", model_column);
	}


	private void create_list_columns (Gee.List<unowned ParamSpec> props) {
		Gtk.CellRenderer cell;

		var count = props.size;
		for (var i = 0; i < count; i++) {
			unowned ParamSpec prop = props[i];
			var column = new Gtk.TreeViewColumn ();
			column.title = dgettext (null, prop.name);
			create_list_column (column, out cell, prop, i + 1);
			insert_column (column, -1);
		}
	}


	private void _set_read_only (bool ro) {
		_read_only = ro;

		var columns = get_columns ();
		unowned List<unowned Gtk.TreeViewColumn> icolumn = columns;
		while (icolumn != null) {
			var cells = icolumn.data.get_cells ();
			unowned List<unowned Gtk.CellRenderer> icell = cells;

			while (icell != null) {
				unowned Gtk.CellRenderer cell = icell.data;

				if (_read_only == true) {
					cell.mode = Gtk.CellRendererMode.INERT;
				} else {
					if ((cell is Gtk.CellRendererText || cell is Gtk.CellRendererCombo ) &&
							(cell as Gtk.CellRendererText).editable == true)
						cell.mode = Gtk.CellRendererMode.EDITABLE;
					if (cell is Gtk.CellRendererToggle && (cell as Gtk.CellRendererToggle).activatable == true)
						cell.mode = Gtk.CellRendererMode.ACTIVATABLE;
				}

				icell = icell.next;
			}

			icolumn = icolumn.next;
		}
	}


	private bool button_released (Gdk.EventButton event) {
		if (menu != null && event.button == 3) {
			if (remove_menu_item != null)
				remove_menu_item.sensitive = this.get_selection ().count_selected_rows () > 0;
			menu.popup (null, null, null, event.button, Gtk.get_current_event_time ());
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


	private void text_cell_edited (Gtk.CellRendererText cell, string _path,
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
			PropertyAdapter ad = {new_text };
			ad_val.set_boxed (&ad);

			/* transform string to property value */
			var val = Value (prop_type);
			if (ad_val.transform (ref val) == false)
				warning ("Could not transform %s to %s",
						ad_val.type ().name (), val.type ().name ());
			entity.set_property (property_name, val);

			/* quick and dirty */
			// list_store.set_value (iter, property_column, val);
		}

		/* Signal handler may chagne entity so we call it before refreshing.
			Same goes for other kinds of cells. */
		row_edited (iter, entity, property_name);
		refresh_row (iter, entity);
	}


	private void toggle_cell_toggled (Gtk.CellRendererToggle cell, string _path) {
		Entity entity;
		Gtk.TreeIter iter;		var path = new Gtk.TreePath.from_string (_path);
		list_store.get_iter (out iter, path);
		list_store.get (iter, 0, out entity);

		var property_name = cell.get_data<string> ("property_name");

		var val = Value (typeof (bool));
		entity.get_property (property_name, ref val);
		val.set_boolean (!val.get_boolean ());
		entity.set_property (property_name, val);

		row_edited (iter, entity, property_name);
		refresh_row (iter, entity);
	}


	private void combo_cell_changed (Gtk.CellRendererCombo cell, string _path,
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
		if (entity == null)
			return;

		Gtk.TreeIter iter;
		list_store.append (out iter);
		refresh_row (iter, entity);
		entity.persist ();
	}


	public void remove_item_clicked () {
		Gtk.TreeIter iter;
		if (this.get_selection ().get_selected (null, out iter) == false)
			return;

		Entity obj;
		list_store.get (iter, 0, out obj);

		var msg = new Gtk.MessageDialog (this.get_toplevel () as Gtk.Window, Gtk.DialogFlags.MODAL,
				Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO,
				"Are you sure you want to delete '%s' and all its data?",
				(obj as Viewable).display_name);
		msg.response.connect ((response_id) => {
			if (response_id == Gtk.ResponseType.YES) {
				remove_entity (obj);
				list_store.remove (ref iter);
			}

			msg.destroy ();
		});
		msg.show ();
	}


	/*
	 * This function clears table and requests new entity list to display.
	 */
	public void refresh_view () {
		/* unselect to prevent emitting selection events when GTK clears the list */
		get_selection ().unselect_all ();

		Gtk.TreeIter iter;
		list_store.clear ();

		var list = get_entity_list ();
		foreach (var entity in list) {
			list_store.append (out iter);
			refresh_row (iter, entity);
		}

		if (list_store.get_iter_first (out iter) == true)
			get_selection ().select_iter (iter);
	}


	/*
	 * This function refershes every row without requesting new entity list.
	 */
	public void refresh_all () {
		Gtk.TreeIter iter;

		if (list_store.get_iter_first (out iter) == true) {
			do {
				Entity entity;
				list_store.get (iter, 0, out entity);
				refresh_row (iter, entity);
			} while (list_store.iter_next (ref iter) == true);
		}
	}


	private void refresh_row (Gtk.TreeIter iter, Entity entity) {
		unowned ObjectClass obj_class = (ObjectClass) entity.get_type ().class_peek ();
		list_store.set (iter, 0, entity);

		unowned string[] props = viewable_props ();
		var count = props.length;
		for (var i = 0; i < count; i++) {
			unowned string prop_name = props[i];
			unowned ParamSpec? prop_spec = obj_class.find_property (prop_name);
			var prop_type = prop_spec.value_type;
			var model_column = i + 1;

			var val = Value (prop_type);
			entity.get_property (prop_name, ref val);

			if (prop_type == typeof (string) || prop_type == typeof (int) ||
					prop_type == typeof (bool)) {
				/* these convert nicely */
				list_store.set_value (iter, model_column, val);
			} else if (prop_type.is_a (typeof (Entity))) {
				/* entity, a special case */
				unowned Object? obj = val.get_object ();
				if (obj != null && obj is Viewable)
					list_store.set (iter, model_column, ((Viewable) obj).display_name);
				else
					list_store.set (iter, model_column, null);
			} else {
				/* first, try usng an adaptor */
				var ad_val = Value (typeof (PropertyAdapter));
				if (val.transform (ref ad_val) == true) {
					val = Value (typeof (string));
					val.set_string (((PropertyAdapter*) ad_val.get_boxed ())->val);
				} else {
					warning ("Could not transform %s to %s",
							prop_type.name (), ad_val.type ().name ());
				}

				list_store.set_value (iter, model_column, val);
			}
		}

		row_refreshed (iter, entity);
	}


	protected bool find_row (out Gtk.TreeIter iter, DB.Entity entity) {
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


	public void find_and_refresh_row (DB.Entity entity) {
		Gtk.TreeIter iter;
		if (find_row (out iter, entity) == true)
			refresh_row (iter, entity);
	}
}


}

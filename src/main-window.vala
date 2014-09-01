namespace Kv {


[GtkTemplate (ui = "/ui/main-window.ui")]
class MainWindow : Gtk.ApplicationWindow {
	[GtkChild]
	private Gtk.ToolButton current_period;

	[GtkChild]
	private Gtk.ListStore account_store;
	[GtkChild]
	private Gtk.TreeView account_list;
	[GtkChild]
	private Gtk.CellRendererText account_list_number;
	[GtkChild]
	private Gtk.CellRendererText account_list_apartment;

	[GtkChild]
	private Gtk.Menu account_menu;
	[GtkChild]
	private Gtk.MenuItem account_menu_remove;

	[GtkChild]
	private Gtk.ListStore people_store;
	[GtkChild]
	private Gtk.TreeView people_list;
	[GtkChild]
	private Gtk.CellRendererText people_list_name;
	[GtkChild]
	private Gtk.CellRendererText people_list_birthday;



	public MainWindow (Application app) {
		Object (application: app);
/*
		var columns = account_list.get_columns ();
		columns.foreach ((column) => {
			var cells = column.get_cells ();
			cells.foreach((cell) => {
				if (cell is Gtk.CellRendererText) {
					(cell as Gtk.CellRendererText).edited.connect ((string path, string new_text) => {
						account_row_edited (cell, path, new_text);
					});
				}
			});
		});
*/
		update_account_list ();
	}


	private void set_current_period (Period period) {
		current_period.label = "%s %d".printf (
				Utils.month_to_string(period.month),
				period.year);
	}


	[GtkCallback]
	private void current_period_clicked () {
	}


	[GtkCallback]
	private bool account_button_released (Gdk.EventButton event) {
		if (event.button == 3) {
			account_menu_remove.sensitive = account_list.get_selection ().count_selected_rows () > 0;
			account_menu.popup (null, null, null, event.button, Gtk.get_current_event_time ());
		}

		return false;
	}


	[GtkCallback]
	private void account_row_edited (Gtk.CellRendererText cell, string path, string new_text) {
		Account account;
		Gtk.TreeIter iter;
		var tree_path = new Gtk.TreePath.from_string (path);

		account_store.get_iter (out iter, tree_path);
		account_store.get (iter, 0, out account);

		if (cell == account_list_number) {
			account.number = new_text;
			account_store.set (iter, 1, new_text);
		} else if (cell == account_list_apartment) {
			account.apartment = new_text;
			account_store.set (iter, 2, new_text);
		}

		(application as Application).update_account (account);
	}


	[GtkCallback]
	private void account_selection_changed () {
		update_people_list ();
//		update_tax_list ();
	}


	[GtkCallback]
	private void add_account_clicked () {
		Account account = (application as Application).add_account ();

		Gtk.TreeIter iter;
		account_store.append (out iter);
		account_store.set (iter, 0, account, 1, account.number, 2, account.apartment);
	}


	[GtkCallback]
	private void remove_account_clicked () {
		Gtk.TreeIter iter;
		if (account_list.get_selection ().get_selected (null, out iter) == false)
			return;

		Account account;
		account_store.get (iter, 0, out account);

		var msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL,
				Gtk.MessageType.QUESTION, Gtk.ButtonsType.YES_NO,
				"Are you sure you want to delete account '%s' and all its data?",
				account.number);
		msg.response.connect ((response_id) => {
			if (response_id == Gtk.ResponseType.YES) {
				update_account_list ();
				update_people_list ();
//				update_tax_list ();
			}
		});
		msg.show ();
	}


	private void update_account_list () {
		Gtk.TreeIter iter;
		account_store.clear ();

		var list = (application as Application).get_account_list ();
		foreach (var account in list) {
			account_store.append (out iter);
			account_store.set (iter, 0, account, 1, account.number, 2, account.apartment);
		}
	}

	/*
	 * People list
	 */
	private void update_people_list () {
		Gtk.TreeIter iter;
		people_store.clear ();

		var list = (application as Application).get_people_list ();
		foreach (var person in list) {
			people_store.append (out iter);
			people_store.set (iter, 0, person, 1, person.name, 2, person.birthday);
		}
	}
}


}

using Gdk;
using Gtk;


namespace DB {


public class CellRendererCalendar : CellRendererText {
	public DateTime time { get; set; }


	public void icon_pressed (Gtk.Entry entry, EntryIconPosition icon_pos, Event event) {
		var cal = new Gtk.Calendar ();
		cal.visible = true;

		var popover = new Gtk.Popover (entry);
		popover.add (cal);
		popover.show ();
	}


	public override unowned CellEditable start_editing (Event event, Widget widget,
			string path, Rectangle background_area, Rectangle cell_area, CellRendererState flags) {
		unowned CellEditable ed = base.start_editing (event, widget, path, background_area, cell_area, flags);

		unowned Gtk.Entry entry = (Gtk.Entry) ed;
		entry.secondary_icon_name = "x-office-calendar";
		entry.icon_press.connect (icon_pressed);

		return ed;
	}
}


}

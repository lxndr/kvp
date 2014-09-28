using Gdk;
using Gtk;


namespace Kv {



private class EditableCalendar : Calendar, CellEditable {
	public void start_editing (Event event) {
	}
}



public class CellRendererCalendar : CellRendererText {
	public DateTime time { get; set; }

	private EditableCalendar? calendar;


	construct {
	}


	private void editing_done (CellEditable ed) {
		var canceled = ed.editing_canceled;
		stop_editing (canceled);
		if (canceled) {
			calendar = null;
			return;
		}

		// edited (path, new_text);
	}


	private void day_selected () {
	}


	private bool focus_out_event (EventFocus event) {
		return false;
	}


	public override unowned CellEditable start_editing (Event event, Widget widget,
			string path, Rectangle background_area, Rectangle cell_area, CellRendererState flags) {
		if (editable == false)
			return null;

		calendar = new EditableCalendar ();
		calendar.show ();
		calendar.editing_done.connect (editing_done);
		calendar.day_selected.connect (day_selected);
		calendar.focus_out_event.connect (focus_out_event);

		return calendar;
	}
}


}

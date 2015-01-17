namespace Kv.Reports {


public abstract class Spreadsheet : Report {
	protected OOXML.Spreadsheet book;
	protected string template_name;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	public override bool prepare () throws Error {
		if (template_name != null)
			book.load (application.template_path ().get_child (template_name));
		return true;
	}


	public override void show () {
		File tmp_file;

		try {
			IOStream tmp_io;
			tmp_file = File.new_tmp ("kvp-report-XXXXXX.xlsx", out tmp_io);
			tmp_io.close ();
			book.save_as (tmp_file);
		} catch (Error e) {
			error ("Error writing the report: %s", e.message);
		}

		try {
#if WINDOWS
			var ai = AppInfo.get_default_for_type (".xlsx", false);
			var l = new List<File> ();
			l.append (tmp_file);
			ai.launch (l, null);
#else
			AppInfo.launch_default_for_uri (tmp_file.get_uri (), null);
#endif
		} catch (Error e) {
			error ("Error opening the report: %s", e.message);
		}
	}


	protected void template_sheet_text (OOXML.Sheet sheet) {
		foreach (var row in sheet.rows) {
			foreach (var cell in row.cells) {
				if (cell.val != null && cell.val is OOXML.SimpleTextValue) {
					var v = (OOXML.SimpleTextValue) cell.val;
					v.text = template_text (v.text);
				}
			}
		}
	}


	protected Gee.List<uint> copy_styles_horz (OOXML.Cell src, int count) {
		var row = src.row;
		var styles = new Gee.ArrayList<uint> ();
		for (var i = src.number; i < src.number + count; i++)
			styles.add (row.get_cell (i).style);
		return styles;
	}


	protected void paste_styles_horz (Gee.List<uint> styles, OOXML.Cell dest) {
		var row = dest.row;
		int cell_number = dest.number;
		foreach (uint style in styles) {
			row.get_cell (cell_number).style = style;
			cell_number++;
		}
	}
}


}

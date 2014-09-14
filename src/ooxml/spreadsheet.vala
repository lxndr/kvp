namespace OOXML {


public class Spreadsheet : Object {
	private Archive.Zip archive;
	private Gee.List<Sheet> sheets;


	public Spreadsheet () {
		archive = new Archive.Zip ();
		sheets = new Gee.ArrayList<Sheet> ();
	}


	public void load (File file) throws GLib.Error {
		archive.open (file);

		/* load shared string */
		var shared_strings = SharedStrings.load_from_xlsx (archive);

		load_workbook (shared_strings);
	}


	private void load_workbook (Gee.List<StringValue> shared_strings) throws GLib.Error {
		var xml_doc = load_xml ("xl/workbook.xml");

		var workbook_node = xml_doc->get_root_element ();
		if (!(workbook_node->name == "workbook" && workbook_node->ns != null &&
				workbook_node->ns->href == "http://schemas.openxmlformats.org/spreadsheetml/2006/main"))
			throw new Error.WORKBOOK ("xl/workbook.xml is incorrect");

		for (Xml.Node* node = workbook_node->children; node != null; node = node->next) {
			if (node->name == "sheets") {
				for (Xml.Node* sheet_node = node->children; sheet_node != null; sheet_node = sheet_node->next) {
					var sheet_id = (uint) uint64.parse (sheet_node->get_prop ("sheetId"));
					load_worksheet (sheet_id, shared_strings);
				}
			}
		}
	}


	private void load_worksheet (uint sheet_id, Gee.List<StringValue> shared_strings) throws GLib.Error {
		var path = "xl/worksheets/sheet%u.xml".printf (sheet_id);
		var xml_doc = load_xml (path);

		var sheet = new Sheet ();
		sheet.load_from_xml (xml_doc, shared_strings);
		sheets.add (sheet);
	}


	private Xml.Doc* load_xml (string path) throws GLib.Error {
		string xml;
		var tmp = archive.extract (path);
		FileUtils.get_contents (tmp.get_path (), out xml);
		return Xml.Parser.read_memory (xml, xml.length);
	}


	public void save_as (File file) throws GLib.Error {
		Gee.List<StringValue> shared_strings = new Gee.ArrayList<StringValue> ();

		for (var i = 0; i < sheets.size; i++)
			store_worksheet (sheets[i], i + 1, shared_strings);

		SharedStrings.store_to_xlsx (shared_strings, archive);
		archive.write (file);
	}


	private void store_worksheet (Sheet sheet, uint sheet_id, Gee.List<StringValue> shared_strings) {
		string xml = sheet.to_xml (shared_strings);

		var path = "xl/worksheets/sheet%u.xml".printf (sheet_id);
		var io = archive.add_from_stream (path);
		io.output_stream.write (xml.data);
	}


	public Sheet sheet (int index) {
		return sheets[index];
	}
}


}

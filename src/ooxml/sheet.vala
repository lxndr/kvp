namespace OOXML {


public class Cell : Object {
	public string name { get; set; }
	public uint style { get; set; default = 0; }
	public CellValue val { get; set; }
}


public class Row : Object {
	public uint number { get; set; }
	public uint style { get; set; default = 0; }
	public bool custom_format { get; set; default = false; }
	public double height { get; set; }
	public bool hidden { get; set; default = false; }
	public bool custom_height { get; set; default = false; }
	public uint8 outline_level { get; set; default = 0; }
	public bool collapsed { get; set; default = false; }
	public bool thick_top { get; set; default = false; }
	public bool thick_bot { get; set; default = false; }
	public bool phonetic { get; set; default = false; }
	public Gee.List<Cell> cells;

	public Row () {
		cells = new Gee.ArrayList<Cell> ();
	}
}


public class Sheet : Object {
	public Gee.List<Row> rows;


	public Sheet () {
		rows = new Gee.ArrayList<Row> ();
	}


	public void load_from_xml (Xml.Doc* xml_doc) throws Error {
		for (var xml_node = xml_doc->children; xml_node != null; xml_node = xml_node->next) {
			switch (xml_node->name) {
			case "sheetData":
				load_sheet_data (xml_node);
				break;
			}
		}
	}


	private void load_sheet_data (Xml.Node* xml_node) throws Error {
		for (var row_node = xml_node->children; row_node != null; row_node = row_node->next) {
			if (row_node->name != "row")
				throw new Error.WORKSHEET ("Unknown xml node '%s' within sheetData", row_node->name);

			var row = new Row ();

			for (var attr = row_node->properties; attr != null; attr = attr->next) {
				unowned string val = attr->children->content;

				switch (attr->name) {
				case "r":
					break;
				case "spans":
					break;
				case "s":
					row.style = (uint) uint64.parse (val);
					break;
				case "customFormat":
					row.custom_format = bool.parse (val);
					break;
				case "ht":
					row.height = double.parse (val);
					break;
				case "hidden":
					row.hidden = bool.parse (val);
					break;
				case "customHeight":
					row.custom_height = bool.parse (val);
					break;
				case "outlineLevel":
					row.outline_level = (uint8) uint64.parse (val);
					break;
				case "collapsed":
					row.collapsed = bool.parse (val);
					break;
				case "thickTop":
					row.thick_top = bool.parse (val);
					break;
				case "thickBot":
					row.thick_bot = bool.parse (val);
					break;
				case "ph":
					row.phonetic = bool.parse (val);
					break;
				default:
					throw new Error.WORKSHEET ("Unknown xml attribute '%s' within sheetData/row", attr->name);
				}
			}

			for (var c_node = row_node->children; c_node != null; c_node = c_node->next) {
				if (c_node->name != "c")
					throw new Error.WORKSHEET ("Unknown xml node '%s' within sheetData/row", c_node->name);

				var cell = new Cell ();

				for (var attr = c_node->attr; attr != null; attr = attr->next) {
					unowned string val = attr->children->content;

					switch (attr->name) {
					case "r":
						break;
					case "s":
						break;
					case "t":
						break;
					default:
						throw new Error.WORKSHEET ("Unknown xml attribute '%s' within sheetData/row/c", attr->name);
					}
				}

				row.cells.add (cell);
			}

			rows.add (row);
		}
	}
}


}

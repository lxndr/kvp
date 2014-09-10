namespace OOXML {


public class Cell : Object {
	public Row row { get; construct; }

	public string name { get; set; }
	public uint style { get; set; default = 0; }
	public CellValue val { get; set; }

	public Cell (Row _row) {
		Object (row: _row);
	}
}


public class Row : Object {
	public Sheet sheet { get; construct; }

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

	public Row (Sheet _sheet) {
		Object (sheet: _sheet);
		cells = new Gee.ArrayList<Cell> ();
	}
}


public class Sheet : Object {
	public Gee.List<Row> rows;
	public Gee.List<Xml.Node*> extra_xml_nodes;


	public Sheet () {
		rows = new Gee.ArrayList<Row> ();
		extra_xml_nodes = new Gee.ArrayList<Xml.Node*> ();
	}


	private void parse_cell_name (string name, out uint x, out uint y) {
		try {
			var re = Regex ("([A-Z]+)([0-9]+)");
			var tokens = re.split (name);

			

			x = (uint) uint64.parse (tokens[1]);
			y = (uint) uint64.parse (tokens[2]);
		} catch (RegexError e) {
			error ("Regex error: %s", e.message);
		}
	}


	private void add_row (Row row) {
		var actual_number = row.number - 1;

		if (actual_number >= rows.size) {
			var last_number = rows.size - 1;
			for (var i = last_number; i < actual_number; i++)
				rows.add (new Cell ());
		}

		rows[row.number - 1] = row;
	}


	public void insert_row (int index) {
		rows.insert (new Row ());
	}


	public Cell get_cell (uint x, uint y) {
		return rows[x - 1][y];
	}


	public void put_value (uint x, uint y, string text) {
		get_cell (x, y).val = StringValue.simple (text);
	}


	public void load_from_xml (Xml.Doc* xml_doc) throws Error {
		for (var xml_node = xml_doc->children; xml_node != null; xml_node = xml_node->next) {
			switch (xml_node->name) {
			case "sheetData":
				load_sheet_data (xml_node);
				break;
			default:
				extra_xml_nodes.add (xml_node->copy (1));
				break;
			}
		}
	}


	private void load_sheet_data (Xml.Node* xml_node) throws Error {
		for (var row_node = xml_node->children; row_node != null; row_node = row_node->next) {
			if (row_node->name != "row")
				throw new Error.WORKSHEET ("Unknown xml node '%s' within sheetData", row_node->name);

			var row = new Row (this);

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

				var cell = new Cell (row);

				for (var attr = c_node->properties; attr != null; attr = attr->next) {
					unowned string val = attr->children->content;

					switch (attr->name) {
					case "r":
						break;
					case "s":
						cell.style = (uint) uint64.parse (val);
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

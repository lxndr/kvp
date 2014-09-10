namespace OOXML {


public class Cell : Object {
	public Row row { get; construct; }

	public int number { get; set; }
	public string name { get; set; }
	public uint style { get; set; default = 0; }
	public CellValue? val { get; set; default = null; }


	public Cell (Row _row) {
		Object (row: _row);
	}


	public Cell.with_name (Row _row) {
		int x, y;
		Utils.parse_cell_name (_name, out x, out y);

		assert (y == _row.number);
		Object (row: _row, name: _name, number: x);
	}


	public bool is_empty () {
		return val == null;
	}
}


public class Row : Object {
	public Sheet sheet { get; construct; }

	public int number { get; set; }
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


	private void grow_cells_if_needed (int needed_cell_number) {
		while (cells.size < needed_cell_number) {
			cells.add (new Cell (this));
		}
	}


	public Cell get_cell (int number) {
		grow_cells_if_needed (number);
		return cells[number - 1];
	}


	public bool is_empty () {
		foreach (var cell in cells)
			if (cell.is_empty () == false)
				return false;

		return true;
	}
}


public class Sheet : Object {
	public Gee.List<Row> rows;
	public Gee.HashMap<string, Xml.Node*> extra_xml_nodes;


	public Sheet () {
		rows = new Gee.ArrayList<Row> ();
		extra_xml_nodes = new Gee.HashMap<string, Xml.Node*> ();
	}


	private void grow_rows_if_needed (int needed_row_number) {
		while (rows.size < needed_row_number) {
			var row = new Row (this);
			rows.add (row);
			row.number = rows.size;
		}
	}


	private void add_row (Row row) {
		grow_rows_if_needed (row.number);
		rows[row.number - 1] = row;
	}


	public void insert_row (int number) {
		grow_rows_if_needed (number);
		rows.insert (number - 1, new Row (this));
	}


	public Cell get_cell (int x, int y) {
		return rows[y - 1].get_cell (x);
	}


	public void put_string (int x, int y, string text) {
		get_cell (x, y).val = new StringValue.simple (text);
	}


	public void load_from_xml (Xml.Doc* xml_doc, Gee.List<StringValue> shared_strings) throws Error {
		Xml.Node* xml_root = xml_doc->get_root_element ();
		if (xml_root->name != "worksheet")
			throw new Error.WORKSHEET ("Unknown xml node '%s' within a worksheet part", xml_root->name);

		for (var xml_node = xml_root->children; xml_node != null; xml_node = xml_node->next) {
			switch (xml_node->name) {
			case "sheetData":
				load_sheet_data (xml_node, shared_strings);
				break;
			default:
				extra_xml_nodes[xml_node->name] = xml_node->copy (1);
				break;
			}
		}
	}


	private void load_sheet_data (Xml.Node* xml_node, Gee.List<StringValue> shared_strings) throws Error {
		for (var row_node = xml_node->children; row_node != null; row_node = row_node->next) {
			if (row_node->name != "row")
				throw new Error.WORKSHEET ("Unknown xml node '%s' within sheetData", row_node->name);

			var row = new Row (this);

			for (var attr = row_node->properties; attr != null; attr = attr->next) {
				unowned string val = attr->children->content;

				switch (attr->name) {
				case "r":
					row.number = (int) int64.parse (val);
					break;
				case "spans":
				case "dyDescent":
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
				string? val;

				/* ref */
				val = c_node->get_prop ("r");
				if (val == null)
					val = "A1"; /* FIXME no no no */
				cell.name = val;

				/* style */
				val = c_node->get_prop ("s");
				if (val == null)
					val = "0";
				cell.style = (uint) uint64.parse (val);

				/* type */
				string? type = c_node->get_prop ("t");
				if (type == null)
					type = "n";

				var v_node = c_node->children;
				if (v_node != null) {
					val = v_node->children->content;

					switch (type) {
					case "n":
						cell.val = new NumberValue.from_string (val);
						break;
					case "s":
						cell.val = shared_strings[(int) int64.parse (val)];
						break;
					case "inlineStr":
						cell.val = new StringValue.simple (val);
						break;
					default:
						throw new Error.WORKSHEET ("Unknown value type '%s' for sheetData/row/cell", type);
					}
				}

				row.cells.add (cell);
			}

			add_row (row);
		}
	}


	public string to_xml () {
		Xml.Doc* xml_doc = new Xml.Doc ("1.0");
		Xml.Node* root_node = xml_doc->new_node (null, "worksheet");
		root_node->set_prop ("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main");

		xml_doc->set_root_element (root_node);

		/* extra nodes */
		string[] top_nodes = {
			"dimension",
			"sheetViews",
			"cols"
		};

		foreach (var name in top_nodes) {
			Xml.Node* xml_node = extra_xml_nodes[name];
			root_node->add_child (xml_node);
		}

		/* sheetData */
		root_node->add_child (sheet_data_to_xml ());

		/* extra nodes */
		string[] bottom_nodes = {
			"pageMargins",
			"pageSetup"
		};

		foreach (var name in bottom_nodes) {
			Xml.Node* xml_node = extra_xml_nodes[name];
			root_node->add_child (xml_node);
		}

		/* dump */
		string xml;
		xml_doc->dump_memory_enc_format (out xml);

//stdout.printf (xml);
//error ("DONE");
		return xml;
	}


	private Xml.Node* sheet_data_to_xml () {
		Xml.Node* root_node = new Xml.Node (null, "sheetData");

		foreach (var row in rows) {
			if (row.is_empty () == true)
				continue;

			Xml.Node* row_node = root_node->new_child (null, "row");
			row_node->set_prop ("r", row.number.to_string ());
			row_node->set_prop ("s", row.style.to_string ());
			row_node->set_prop ("customFormat", row.custom_format.to_string ());
			row_node->set_prop ("ht", row.height.to_string ());

			foreach (var cell in row.cells) {
				if (cell.is_empty () == true)
					continue;

				Xml.Node* cell_node = row_node->new_child (null, "c");
				cell_node->set_prop ("r", cell.name);
				cell_node->set_prop ("s", cell.style.to_string ());

				if (cell.val is StringValue) {
					var cell_val = cell.val as StringValue;
					cell_node->set_prop ("t", "inlineStr");
					Xml.Node* v_node = cell_node->new_text_child (null, "v", cell_val.to_string ());
				}
			}
		}

		return root_node;
	}
}


}

namespace OOXML {


public class Cell : Object {
	public Row row { get; construct; }

	public uint style { get; set; default = 0; }
	public CellValue? val { get; set; default = null; }


	public string get_name () {
		return Utils.format_cell_name (row.number, number);
	}


	public int number {
		get { return row.cell_number (this); }
	}


	public Cell (Row _row) {
		Object (row: _row);
	}


	public bool is_empty () {
		return val == null && style == 0;
	}


	public unowned Cell empty () {
		val = null;
		return this;
	}


	public unowned Cell put_string (string text) {
		val = new StringValue.simple (text);
		return this;
	}
}


public class Row : Object {
	public Sheet sheet { get; construct; }

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


	public int number {
		get { return sheet.row_number (this); }
	}


	public Row (Sheet _sheet) {
		Object (sheet: _sheet);
		cells = new Gee.ArrayList<Cell> ();
	}


	private void grow_cells_if_needed (int needed_cell_number) {
		while (cells.size < needed_cell_number)
			cells.add (new Cell (this));
	}


	public int cell_number (Cell cell) {
		return cells.index_of (cell) + 1;
	}


	public Cell get_cell (int number) {
		grow_cells_if_needed (number);
		return cells[number - 1];
	}


	public void set_cell (int number, Cell cell) {
		grow_cells_if_needed (number);
		cells[number - 1] = cell;
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
		while (rows.size < needed_row_number)
			rows.add (new Row (this));
		stdout.printf ("GROW ROWS.SIZE %d FOR NUMBER %d\n", rows.size, needed_row_number);
	}


	public int row_number (Row row) {
		return rows.index_of (row) + 1;
	}


	public Row get_row (int number) {
		grow_rows_if_needed (number);
		return rows[number - 1];
	}


	public void set_row (int number, Row row) {
		grow_rows_if_needed (number);
		rows[number - 1] = row;
	}


	public void insert_row (int number) {
		grow_rows_if_needed (number);
		rows.insert (number - 1, new Row (this));
	}


	public Cell get_cell (string cell_name) {
		int row_number;
		int cell_number;

		Utils.parse_cell_name (cell_name, out row_number, out cell_number);
		return get_row (row_number).get_cell (cell_number);
	}


	public void put_string (string cell_name, string text) {
		get_cell (cell_name).put_string (text);
	}


	public void put_number (string cell_name, double number) {
		get_cell (cell_name).val = new NumberValue (number);
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

			int row_number = 0;
			var row = new Row (this);

			for (var attr = row_node->properties; attr != null; attr = attr->next) {
				unowned string val = attr->children->content;

				switch (attr->name) {
				case "r":
					row_number = (int) int64.parse (val);
					break;
				case "spans":
				case "dyDescent":
					break;
				case "s":
					row.style = (uint) uint64.parse (val);
					break;
				case "customFormat":
					row.custom_format = Utils.parse_bool (val);
					break;
				case "ht":
					row.height = double.parse (val);
					break;
				case "hidden":
					row.hidden = Utils.parse_bool (val);
					break;
				case "customHeight":
					row.custom_height = Utils.parse_bool (val);
					break;
				case "outlineLevel":
					row.outline_level = (uint8) uint64.parse (val);
					break;
				case "collapsed":
					row.collapsed = Utils.parse_bool (val);
					break;
				case "thickTop":
					row.thick_top = Utils.parse_bool (val);
					break;
				case "thickBot":
					row.thick_bot = Utils.parse_bool (val);
					break;
				case "ph":
					row.phonetic = Utils.parse_bool (val);
					break;
				default:
					throw new Error.WORKSHEET ("Unknown xml attribute '%s' within sheetData/row", attr->name);
				}
			}

			set_row (row_number, row);

			for (var c_node = row_node->children; c_node != null; c_node = c_node->next) {
				if (c_node->name != "c")
					throw new Error.WORKSHEET ("Unknown xml node '%s' within sheetData/row", c_node->name);

				int cell_number = 0;
				var cell = new Cell (row);
				string? val;

				/* ref */



				val = c_node->get_prop ("r");
				if (val == null)
					val = "A1"; /* FIXME no no no */
stdout.printf ("CELL %s\n", val);
				int y;
				Utils.parse_cell_name (val, out y, out cell_number);
stdout.printf ("\t c%d r%d\n", cell_number, y);
				assert (y == row_number);

				row.set_cell (cell_number, cell);
stdout.printf ("\t c%d r%d = %s\n", cell.number, cell.row.number, cell.get_name ());
				assert (val == cell.get_name ());

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
			}
		}
	}


	public string to_xml (Gee.List<StringValue> shared_strings) {
		Xml.Doc* xml_doc = new Xml.Doc ("1.0");
		Xml.Node* root_node = xml_doc->new_node (null, "worksheet");
		root_node->set_prop ("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main");

		xml_doc->set_root_element (root_node);

		/* extra nodes */
		string[] top_nodes = {
			"dimension",
			"sheetViews",
			"sheetFormatPr",
			"cols"
		};

		foreach (var name in top_nodes) {
			Xml.Node* xml_node = extra_xml_nodes[name];
			root_node->add_child (xml_node);
		}

		/* sheetData */
		root_node->add_child (sheet_data_to_xml (shared_strings));

		/* extra nodes */
		string[] bottom_nodes = {
			"mergeCells",
			"printOptions",
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

stdout.printf (xml);

		return xml;
	}


	private Xml.Node* sheet_data_to_xml (Gee.List<StringValue> shared_strings) {
		Xml.Node* root_node = new Xml.Node (null, "sheetData");

		foreach (var row in rows) {
			if (row.is_empty () == true)
				continue;

			Xml.Node* row_node = root_node->new_child (null, "row");
			row_node->set_prop ("r", row.number.to_string ());
			row_node->set_prop ("s", row.style.to_string ());
			row_node->set_prop ("customFormat", row.custom_format.to_string ());
			row_node->set_prop ("ht", row.height.to_string ());
			row_node->set_prop ("customHeight", row.custom_height.to_string ());
			row_node->set_prop ("tickTop", row.thick_top.to_string ());

			foreach (var cell in row.cells) {
				if (cell.is_empty () == true)
					continue;

				Xml.Node* cell_node = row_node->new_child (null, "c");
				cell_node->set_prop ("r", cell.get_name ());
				cell_node->set_prop ("s", cell.style.to_string ());

				if (cell.val is StringValue) {
					var cell_val = cell.val as StringValue;
					cell_node->set_prop ("t", "s");

					var string_number = shared_strings.index_of (cell_val);
					if (string_number == -1) {
						shared_strings.add (cell_val);
						string_number = shared_strings.size - 1;
					}

					cell_node->new_text_child (null, "v", string_number.to_string ());
				}
			}
		}

		return root_node;
	}
}


}

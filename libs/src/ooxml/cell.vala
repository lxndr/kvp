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


}

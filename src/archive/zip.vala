namespace Archive {


public class Zip {
	private struct CentralDirectory {
		public uint16 version;
		public uint16 version_needed;
		public uint16 general_flags;
		public uint16 compression_method;
		public uint16 mod_time;
		public uint16 mod_date;
		public uint32 crc32;
		public uint32 compressed_size;
		public uint32 uncompressed_size;
		public string file_name;
		public string comment;
		public Bytes extra_field;
		public uint16 disk_number_start;
		public uint16 internal_attrs;
		public uint32 external_attrs;
		public uint32 header_offset;
	}


	Gee.List<CentralDirectory?> cdir_list;
	Gee.Map<string, GLib.File> file_list;		/* this is changed and new files */


	public Zip () {
		cdir_list = new Gee.ArrayList<CentralDirectory?> ();
		file_list = new Gee.HashMap<string, GLib.File> ();
	}


	private GLib.File extract (string path) {
		var file = file_list[path];
		if (file != null)
			return file;

		if (file == null) {
			FileIOStream ios;
			file = GLib.Path.new_tmp (null, out ios);
			file_list[path] = file;
		}
	}


	public InputStream read_file (string path) {
		var file = file_list[path];
		if (file == null) {
			FileIOStream ios;
			file = GLib.Path.new_tmp (null, out ios);
			file_list[path] = file;
			return ios.input_stream;
		} else {
			return file.read ();
		}
	}


	private string read_string (InputStream stm, size_t length) {
		var buf = string.nfill (length, '.');
		stm.read (buf.data);
		return buf;
	}


	private CentralDirectory read_cdir (DataInputStream stm) throws IOError {
		CentralDirectory cdir = {};

		var sig = stm.read_uint32 ();
		if (sig != 0x02014b50)
			error ("Wrong signature of Central Directory");

		cdir.version = stm.read_uint16 ();
		cdir.version_needed = stm.read_uint16 ();
		cdir.general_flags = stm.read_uint16 ();
		cdir.compression_method = stm.read_uint16 ();
		cdir.mod_time = stm.read_uint16 ();
		cdir.mod_date = stm.read_uint16 ();
		cdir.crc32 = stm.read_uint32 ();
		cdir.compressed_size = stm.read_uint32 ();
		cdir.uncompressed_size = stm.read_uint32 ();
		var fname_length = stm.read_uint16 ();
		var efield_length = stm.read_uint16 ();
		var comment_length = stm.read_uint16 ();
		cdir.disk_number_start = stm.read_uint16 ();
		cdir.internal_attrs = stm.read_uint16 ();
		cdir.external_attrs = stm.read_uint32 ();
		cdir.header_offset = stm.read_uint32 ();

		cdir.file_name = read_string (stm, fname_length);
		cdir.extra_field = stm.read_bytes (efield_length);
		cdir.comment = read_string (stm, comment_length);

		return cdir;
	}


	public void open (GLib.File f) throws IOError {
		var stm = new DataInputStream (f.read ());
		stm.byte_order = DataStreamByteOrder.LITTLE_ENDIAN;


		/* reading End of Central Directory */
		/* FIXME: it has to do some searching */
		stm.seek (-0x16, SeekType.END);
		var sig = stm.read_uint32 ();
		if (sig != 0x06054b50)
			error ("Could not find End of Central Directory");

		stm.skip (2); /*  */
		stm.skip (2); /*  */

		var cdir_count = stm.read_uint16 ();

		stm.skip (2); /*  */

		var cdir_size = stm.read_uint32 ();
		var cdir_offset = stm.read_uint32 ();

		stm.seek (cdir_offset, SeekType.SET);
		for (var i = 0; i < cdir_count; i++)
			cdir_list.add (read_cdir (stm));


#if 0
		var end_offset = stm.tell ();
		stm.seek (0, SeekType.SET);

		while (stm.tell () < end_offset) {
			var sig = stm.read_uint32 ();
			if (sig != 0x04034b50)
				error ("Unknown Zip signature 0x%X", sig);

			var version = stm.read_uint16 ();

			var general_flags = stm.read_uint16 ();
			if ((general_flags & 0x00000008) > 0)
				stdout.printf ("bit3\n");

			var compression_method = stm.read_uint16 ();

			var mod_file_time = stm.read_uint16 ();

			var mod_file_date = stm.read_uint16 ();

			var crc32 = stm.read_uint32 ();

			var compressed_size = stm.read_uint32 ();

			var uncompressed_size = stm.read_uint32 ();

			var name_length = stm.read_uint16 ();
			var extra_length = stm.read_uint16 ();
			if (extra_length > 0)
				stdout.printf ("Got extra field\n");

			var file_name = read_string (stm, name_length);
			stdout.printf ("File: %s\n", file_name);

			stm.skip (extra_length);

			stm.skip (compressed_size);
		}
#endif

	}
}


}

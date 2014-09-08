namespace Archive {


public class Zip {
	private struct CentralDirectory {
		public uint16 version;
		public uint16 version_needed;
		public uint16 flags;
		public uint16 compression_method;
		public uint16 mod_time;
		public uint16 mod_date;
		public uint32 crc32;
		public uint32 compressed_size;
		public uint32 uncompressed_size;
		public string fname;
		public string comment;
		public Bytes extra;
		public uint16 disk_number_start;
		public uint16 internal_attrs;
		public uint32 external_attrs;
		public uint32 header_offset;
	}


	private DataInputStream fstm;
	private Gee.List<CentralDirectory?> cdir_list;
	private Gee.Map<string, GLib.File> file_list;
	private Gee.Map<string, GLib.File> changed_files;	/* this is changed and new files */


	public Zip () {
		cdir_list = new Gee.ArrayList<CentralDirectory?> ();
		file_list = new Gee.HashMap<string, GLib.File> ();
		changed_files  = new Gee.HashMap<string, GLib.File> ();
	}


	private GLib.File extract (string path) throws Error {
		var file = file_list[path];
		if (file != null)
			return file;

		var cdir = find_cdir (path);
		if (cdir == null)
			error ("Could not find file '%s' in zip archive", path);

		fstm.seek (cdir.header_offset, SeekType.SET);

		/* read file header */
		var sig = fstm.read_uint32 ();
		if (sig != 0x04034b50)
			error ("Ain't local header");

		var version = fstm.read_uint16 ();
		if (version != 0x14)
			error ("Unsupported version");

		var general_flags = fstm.read_uint16 ();
		if ((general_flags & 0x00000004) > 0)
			stdout.printf ("bit3\n");

		var compression_method = fstm.read_uint16 ();
		if (compression_method != cdir.compression_method)
			error ("compression_method mismatch");

		var mod_file_time = fstm.read_uint16 ();
		if (mod_file_time != cdir.mod_time)
			error ("mod_time mismatch");

		var mod_file_date = fstm.read_uint16 ();
		if (mod_file_date != cdir.mod_date)
			error ("mod_date mismatch");

		var crc32 = fstm.read_uint32 ();
		if (crc32 != cdir.crc32)
			warning ("crc32 mismatch %llx - %llx", crc32, cdir.crc32);

		var compressed_size = fstm.read_uint32 ();
		if (compressed_size != cdir.compressed_size)
			warning ("compressed_size mismatch %ld - %ld", compressed_size, cdir.compressed_size);

		var uncompressed_size = fstm.read_uint32 ();
		if (uncompressed_size != cdir.uncompressed_size)
			warning ("uncompressed_size mismatch %ld - %ld", uncompressed_size, cdir.uncompressed_size);

		var name_length = fstm.read_uint16 ();
		var extra_length = fstm.read_uint16 ();
		if (extra_length > 0)
			stdout.printf ("Got extra field\n");

		var file_name = read_string (fstm, name_length);
		if (file_name != cdir.fname)
			error ("file_name mismatch");

		fstm.skip (extra_length);

		Bytes zdata = fstm.read_bytes (cdir.compressed_size);
		var src_stm = new MemoryInputStream.from_bytes (zdata);

		FileIOStream io;
		file = GLib.File.new_tmp (null, out io);

		var conv = new ZlibDecompressor (ZlibCompressorFormat.RAW);
		var conv_stm = new ConverterOutputStream (io.output_stream, conv);
		conv_stm.splice (src_stm, 0);
		io.close ();

		file_list[path] = file;
		return file;
	}


	public InputStream read_file (string path) throws Error {
		return extract (path).read ();
	}


/*	public OutputStream replace_file (string path) throws Error {
		var file = extract (path);
		
	}*/


	private CentralDirectory? find_cdir (string path) {
		foreach (var cdir in cdir_list)
			if (cdir.fname == path)
				return cdir;
		return null;
	}


	public void write (File f) throws Error {
		FileIOStream io;
		var tmp = GLib.File.new_tmp (null, out io);
		var stm = new DataOutputStream (io.output_stream);
		stm.byte_order = DataStreamByteOrder.LITTLE_ENDIAN;

		foreach (var cdir in cdir_list) {
			var offset = stm.tell ();

			/* write local header */
			stm.put_uint32 (0x04034b50);
			stm.put_uint16 (cdir.version);
			stm.put_uint16 (cdir.flags);
			stm.put_uint16 (cdir.compression_method);
			stm.put_uint16 (cdir.mod_time);
			stm.put_uint16 (cdir.mod_date);
			stm.put_uint32 (0);
			stm.put_uint32 (0);
			stm.put_uint32 (0);
			stm.put_uint16 ((uint16) cdir.fname.length);
			stm.put_uint16 ((uint16) cdir.extra.length);
			stm.put_string (cdir.fname);
			stm.write_bytes (cdir.extra);

			/* copy data */
			fstm.seek (cdir.header_offset, SeekType.SET);
			fstm.skip (0x1e + cdir.fname.length + cdir.extra.length);
			Bytes data = fstm.read_bytes (cdir.compressed_size);
			stm.write_bytes (data);

			/* write data descriptor */
			stm.put_uint32 (0x08074b50);
			stm.put_uint32 (cdir.crc32);
			stm.put_uint32 (cdir.compressed_size);
			stm.put_uint32 (cdir.uncompressed_size);

			cdir.header_offset = (uint32) offset;
		}

		var cdir_offset = stm.tell ();

		foreach (var cdir in cdir_list) {
			/* write central directory header */
			stm.put_uint32 (0x02014b50);
			stm.put_uint16 (cdir.version);
			stm.put_uint16 (cdir.version_needed);
			stm.put_uint16 (cdir.flags);
			stm.put_uint16 (cdir.compression_method);
			stm.put_uint16 (cdir.mod_time);
			stm.put_uint16 (cdir.mod_date);
			stm.put_uint32 (cdir.crc32);
			stm.put_uint32 (cdir.compressed_size);
			stm.put_uint32 (cdir.uncompressed_size);
			stm.put_uint16 ((uint16)cdir.fname.length);
			stm.put_uint16 ((uint16)cdir.extra.length);
			stm.put_uint16 ((uint16)cdir.comment.length);
			stm.put_uint16 (cdir.disk_number_start);
			stm.put_uint16 (cdir.internal_attrs);
			stm.put_uint32 (cdir.external_attrs);
			stm.put_uint32 (cdir.header_offset);

			stm.put_string (cdir.fname);
			stm.write_bytes (cdir.extra);
			stm.put_string (cdir.comment);
		}

		var cdir_size = stm.tell () - cdir_offset;

		/* write end of central directory */
		stm.put_uint32 (0x06054b50);
		stm.put_uint16 (0);
		stm.put_uint16 (0);
		stm.put_uint16 ((uint16) cdir_list.size);
		stm.put_uint16 ((uint16) cdir_list.size);
		stm.put_uint32 ((uint32) cdir_size);
		stm.put_uint32 ((uint32) cdir_offset);
		stm.put_uint16 (0);

		fstm.close ();
		tmp.move (f, FileCopyFlags.OVERWRITE);
	}


	private string read_string (InputStream stm, size_t length) throws IOError {
		var buf = string.nfill (length, '.');
		stm.read (buf.data);
		return buf;
	}


	private void read_central_directory (int64 end_offset) throws Error {
		CentralDirectory cdir = {};

		while (fstm.tell () < end_offset) {
			var sig = fstm.read_uint32 ();
			if (sig != 0x02014b50)
				error ("Wrong signature for Central Directory");

			cdir.version             = fstm.read_uint16 ();
			cdir.version_needed      = fstm.read_uint16 ();
			cdir.flags               = fstm.read_uint16 ();
			cdir.compression_method  = fstm.read_uint16 ();
			cdir.mod_time            = fstm.read_uint16 ();
			cdir.mod_date            = fstm.read_uint16 ();
			cdir.crc32               = fstm.read_uint32 ();
			cdir.compressed_size     = fstm.read_uint32 ();
			cdir.uncompressed_size   = fstm.read_uint32 ();
			var fname_length         = fstm.read_uint16 ();
			var extra_length         = fstm.read_uint16 ();
			var comment_length       = fstm.read_uint16 ();
			cdir.disk_number_start   = fstm.read_uint16 ();
			cdir.internal_attrs      = fstm.read_uint16 ();
			cdir.external_attrs      = fstm.read_uint32 ();
			cdir.header_offset       = fstm.read_uint32 ();

			cdir.fname               = read_string (fstm, fname_length);
			cdir.extra               = fstm.read_bytes (extra_length);
			cdir.comment             = read_string (fstm, comment_length);

			cdir_list.add (cdir);
			stdout.printf ("FILE: %s (%ld, %ld), Flags: 0x%04X\n", cdir.fname,
					cdir.compressed_size, cdir.uncompressed_size, cdir.flags);
		}
	}


	public void open (GLib.File f) throws Error {
		fstm = new DataInputStream (f.read ());
		fstm.byte_order = DataStreamByteOrder.LITTLE_ENDIAN;

		/* reading End of Central Directory */
		/* FIXME: it has to do some searching */
		fstm.seek (-0x16, SeekType.END);
		var sig = fstm.read_uint32 ();
		if (sig != 0x06054b50)
			error ("Could not find End of Central Directory");

		fstm.skip (2); /*  */
		fstm.skip (2); /*  */
		fstm.skip (2); /*  */
		fstm.skip (2); /*  */

		var cdir_size = fstm.read_uint32 ();
		var cdir_offset = fstm.read_uint32 ();

		fstm.seek (cdir_offset, SeekType.SET);
		read_central_directory (cdir_offset + cdir_size);
	}
}


}

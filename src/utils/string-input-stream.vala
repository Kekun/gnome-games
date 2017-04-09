// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.StringInputStream : Object {
	private File file;

	public StringInputStream (File file) {
		this.file = file;
	}

	public bool has_string (size_t offset, string value) throws Error {
		return read_string_for_size (offset, value.length) == value;
	}

	public string read_string (size_t offset) throws Error {
		var stream = new DataInputStream (file.read ());
		stream.seek (offset, SeekType.SET);

		size_t length;

		return stream.read_upto ("\0", 1, out length);
	}

	public string read_string_for_size (size_t offset, size_t size) throws Error {
		var stream = file.read ();
		stream.seek (offset, SeekType.SET);

		var buffer = new uint8[size];
		stream.read (buffer);

		return (string) buffer;
	}
}

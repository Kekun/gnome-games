// This file is part of GNOME Games. License: GPLv3

private class Games.SnesGame : Object, Game {
	private const string MODULE_BASENAME = "libretro-snes.so";

	private const ulong BASE_ROM_SIZE = 0x40000;

	private const ulong HEADER_OFFSET = 0x7fc0;
	private const ulong HEADER_SIZE = 0x200;
	private const ulong HIROM_SIZE = 0x8000;
	private const ulong NAME_OFFSET = 0;
	private const ulong NAME_SIZE = 21;

	private string _name;
	public string name {
		get { return _name; }
	}

	public Icon? icon {
		get { return null; }
	}

	public Gdk.Pixbuf? cover {
		get { return null; }
	}

	public Gdk.Pixbuf? screenshot {
		get { return null; }
	}

	public bool running {
		get { return false; }
	}

	private string path;

	public SnesGame (string uri) throws Error {
		// Information on SNES header: http://romhack.wikia.com/wiki/SNES_header
		var file = File.new_for_uri (uri);
		path = file.get_path ();

		var istream = file.read ();

		var header_offset = HEADER_OFFSET;

		istream.seek (0, SeekType.END);
		var size = istream.tell ();

		// Check wether the ROM is a LoROM or a HiROM
		/*
		if (???) // FIXME: How to check that the ROM is a HiROM?
			header_offset += HIROM_SIZE;
		*/

		// Check wether the ROM is headered or not
		if (size % BASE_ROM_SIZE != 0)
			header_offset += HEADER_SIZE;

		istream.seek (header_offset, SeekType.SET);

		var name_buffer = new uint8[NAME_SIZE];
		istream.read (name_buffer);

		name_buffer += '\0';

		var name = (string) name_buffer;
		_name = name.strip ();
	}

	public Runner get_runner () {
		return new RetroRunner (MODULE_BASENAME, path);
	}
}


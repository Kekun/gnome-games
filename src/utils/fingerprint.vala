// This file is part of GNOME Games. License: GPL-3.0+.

namespace Games.Fingerprint {
	private string get_for_file_uri (string uri, size_t start, size_t? length) throws Error {
		var file = File.new_for_uri (uri);
		var istream = file.read ();

		return get_for_file_input_stream (istream, start, length);
	}

	private string get_for_file_input_stream (FileInputStream file_stream, size_t start, size_t? length) throws Error {
		size_t size;
		if (length == null) {
			file_stream.seek (0, SeekType.END);
			size = (size_t) file_stream.tell ();
		}
		else
			size = length;

		file_stream.seek (start, SeekType.SET);
		var bytes = file_stream.read_bytes (size);

		return Checksum.compute_for_bytes (ChecksumType.MD5, bytes);
	}
}

public class Games.FingerprintUid: Object, Uid {
	private string uri;
	private string prefix;
	private size_t start;
	private size_t? length;
	private string uid;

	public FingerprintUid (string uri, string prefix) {
		this.uri = uri;
		this.prefix = prefix;
		start = 0;
		length = null;
	}

	public FingerprintUid.for_chunk (string uri, string prefix, size_t start, size_t length) {
		this.uri = uri;
		this.prefix = prefix;
		this.start = start;
		this.length = length;
	}

	public string get_uid () throws Error {
		if (uid != null)
			return uid;

		var fingerprint = Fingerprint.get_for_file_uri (uri, start, length);
		uid = @"$prefix-$fingerprint";

		return uid;
	}
}

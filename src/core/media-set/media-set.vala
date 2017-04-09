// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.MediaSet : Object {
	public delegate void MediaCallback (Media media);

	public int selected_media_number { set; get; default = 0; }
	public GLib.Icon? icon { private set; get; }

	private Media[] medias;

	public MediaSet (Media[] medias, GLib.Icon? icon = null) {
		this.medias = medias;
		this.icon = icon;
	}

	public int get_size () {
		return medias.length;
	}

	public Media get_selected_media (uint index) throws Error {
		return get_media (selected_media_number);
	}

	public void foreach_media (MediaCallback media_callback) {
		foreach (var media in medias)
			media_callback (media);
	}

	private Media get_media (uint index) throws Error {
		if (index >= medias.length)
			throw new MediaSetError.NOT_A_MEDIA (_("Invalid media index %u."), index);

		return medias[index];
	}
}

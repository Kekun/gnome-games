// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.SteamTitle : Object, Title {
	private SteamRegistry registry;
	private string name;

	public SteamTitle (SteamRegistry registry) {
		this.registry = registry;
	}

	public string get_title () throws Error {
		if (name != null)
			return name;

		name = registry.get_data ({"AppState", "name"});
		if (name == null)
			throw new SteamError.NO_NAME (_("Couldn’t get name from Steam registry."));

		return name;
	}
}

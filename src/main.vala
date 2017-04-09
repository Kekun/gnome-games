// This file is part of GNOME Games. License: GPL-3.0+.

private extern const string GETTEXT_PACKAGE;
private extern const string GNOMELOCALEDIR;

int main (string[] args) {
	Intl.bindtextdomain (GETTEXT_PACKAGE, GNOMELOCALEDIR);
	Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
	Intl.textdomain (GETTEXT_PACKAGE);

	Grl.init (ref args);

	var app = new Games.Application ();
	var result = app.run (args);

	Grl.deinit ();

	return result;
}

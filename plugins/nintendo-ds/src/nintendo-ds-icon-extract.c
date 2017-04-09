/*
 * Copyright (C) 2007, 2013 Bastien Nocera <hadess@hadess.net>
 *
 * Authors: Bastien Nocera <hadess@hadess.net>
 * Thomas Köckerbauer <tkoecker@gmx.net>
 * Adrien Plazas <kekun.plazas@laposte.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 */

/* Extracted from https://git.gnome.org/browse/gnome-nds-thumbnailer/. */

#include <string.h>
#include <glib.h>
#include <gio/gio.h>
#include <gdk-pixbuf/gdk-pixbuf.h>

/* From specs at http://www.bottledlight.com/ds/index.php/FileFormats/NDSFormat
 * and code at http://www.kde-apps.org/content/show.php?content=39247 */

#define BOUND_ERROR(x) {											\
	if (error != NULL)											\
		return NULL;											\
	else													\
		g_set_error (error, 0, 0, "Couldn’t access file data at 0x%x, probably not a NDS ROM", x);	\
	if (stream != NULL)											\
		g_object_unref (stream);									\
	return NULL;												\
}

#define LOGO_OFFSET_OFFSET 0x068
#define BANNER_LENGTH 2112
#define TILE_DATA_OFFSET 32
#define TILE_DATA_LENGTH 512
#define PALETTE_DATA_OFFSET TILE_DATA_OFFSET + 512
#define PALETTE_DATA_LENGTH 32

struct palette_i {
	guint8 r;
	guint8 g;
	guint8 b;
	guint8 a;
};

static void
put_pixel (guchar *pixels, int rowstride, int x, int y, struct palette_i item)
{
	int n_channels;
	guchar *p;

	n_channels = 4;

	p = pixels + y * rowstride + x * n_channels;
	p[0] = item.r;
	p[1] = item.g;
	p[2] = item.b;
	p[3] = item.a;
}

static GdkPixbuf *
load_icon (gchar *tile_data, guint16 *palette_data)
{
	struct palette_i palette[16];
	int pos, j, i, y, x;

	GdkPixbuf *pixbuf;
	guchar *pixels;
	int rowstride;

	/* Parse the palette */
	for (i = 0; i < 16; i++) {
		palette[i].r = (palette_data[i] & 0x001F) << 3;
		palette[i].g = (palette_data[i] & 0x03E0) >> 2;
		palette[i].b = (palette_data[i] & 0x7C00) >> 7;
		palette[i].a = (i == 0) ? 0x00 : 0xFF;
	}

	/* Create the pixbuf */
	pixbuf = gdk_pixbuf_new (GDK_COLORSPACE_RGB, TRUE, 8, 32, 32);
	rowstride = gdk_pixbuf_get_rowstride (pixbuf);
	pixels = gdk_pixbuf_get_pixels (pixbuf);

	/* Put the grid of icon data into the pixbuf */
	pos = 0;
	for (j = 0; j < 4; j++) {
		for (i = 0; i < 4; i++) {
			for (y = 0; y < 8; y++) {
				for (x = 0; x < 4; x++) {
					put_pixel (pixels, rowstride, x * 2 + 8 * i,  y + 8 * j, palette[tile_data[pos] & 0x0F]);
					put_pixel (pixels, rowstride, x * 2 + 1 + 8 * i, y + 8 * j, palette[(tile_data[pos] & 0xF0)>>4]);
					pos++;
				}
			}
		}
	}

	return pixbuf;
}

GdkPixbuf *
games_nintendo_ds_icon_extract (const char  *uri,
		GError     **error)
{
	GFile *input;
	GFileInputStream *stream;
	GdkPixbuf *pixbuf;

	guint32 offset;
	gchar *tile_data;
	guint16 *palette_data;

	guint32 logo_offset[4];
	char *banner_data;

	/* Open the file for reading */
	input = g_file_new_for_uri (uri);
	stream = g_file_read (input, NULL, error);
	g_object_unref (input);

	if (stream == NULL)
		return NULL;

	/* Get the address of the logo */
	if (g_input_stream_skip (G_INPUT_STREAM (stream), LOGO_OFFSET_OFFSET, NULL, error) == FALSE)
		BOUND_ERROR(LOGO_OFFSET_OFFSET);
	if (g_input_stream_read (G_INPUT_STREAM (stream), &logo_offset, sizeof(guint32), NULL, error) == FALSE)
		BOUND_ERROR(LOGO_OFFSET_OFFSET);
	offset = GUINT32_FROM_LE(*logo_offset) - g_seekable_tell (G_SEEKABLE (stream));

	/* Get the icon data */
	if (g_input_stream_skip (G_INPUT_STREAM (stream), offset, NULL, error) != offset)
		BOUND_ERROR(offset);
	banner_data = g_malloc0(BANNER_LENGTH);
	if (g_input_stream_read (G_INPUT_STREAM (stream), banner_data, BANNER_LENGTH, NULL, error) != BANNER_LENGTH)
		BOUND_ERROR(LOGO_OFFSET_OFFSET);

	g_input_stream_close (G_INPUT_STREAM (stream), NULL, NULL);
	g_object_unref (stream);

	/* Check the version is version 1, 3 or 19 (NDSi) */
	if ((banner_data[0] != 0x1 || banner_data[1] != 0x0) &&
	    (banner_data[0] != 0x3 || banner_data[1] != 0x0) &&
	    (banner_data[0] != 0x3 || banner_data[1] != 0x1)) {
		g_free (banner_data);
		g_set_error (error, 0, 0, "Unsupported icon version, probably not an NDS file");
		return NULL;
	}

	/* Get the tile and palette data for the logo */
	tile_data = g_memdup (banner_data + TILE_DATA_OFFSET, TILE_DATA_LENGTH);
	palette_data = g_memdup (banner_data + PALETTE_DATA_OFFSET, PALETTE_DATA_LENGTH);
	g_free (banner_data);
	pixbuf = load_icon (tile_data, palette_data);
	g_free (palette_data);
	g_free (tile_data);

	return pixbuf;
}

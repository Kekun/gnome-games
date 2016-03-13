#!/bin/env python3

from xml.dom import minidom
import xml.etree.ElementTree as ET

def _filter_empty_lines(text):
    output = ''
    for line in text.splitlines():
        if (line.strip() is not ''):
            output += line + '\n'
    return output

def _quote(text):
    if "'" not in text: return "'%s'" % text
    if '"' not in text: return '"%s"' % text
    return "concat('%s')" % text.replace("'", "',\"'\",'")

class Gameinfo:
    def merged(gameinfo_files):
        if len(gameinfo_files) < 1:
            return None
        if len(gameinfo_files) < 2:
            return Gameinfo(gameinfo_files[0])

        gameinfos = []
        for gameinfo_file in gameinfo_files:
            gameinfos.append(Gameinfo(gameinfo_file))
        gameinfos[0].merge(gameinfos[1:])

        return gameinfos[0]

    def __init__(self, gameinfo_file = None):
        if gameinfo_file is None:
            self.gameinfo = ET.Element('gameinfo')
            self.games = ET.SubElement(self.gameinfo, 'games')
        else:
            tree = ET.parse(gameinfo_file)
            self.gameinfo = tree.getroot()
            self.games = self.gameinfo.find('games')

    def __str__(self):
        self._sort()
        dump = ET.tostring(self.gameinfo)
        reparsed = minidom.parseString(dump)
        pretty = reparsed.toprettyxml(indent='  ')
        return _filter_empty_lines(pretty)

    def __unicode__(self):
        self._sort()
        dump = ET.tostring(self.gameinfo, encoding='unicode')
        reparsed = minidom.parseString(dump)
        return reparsed.toprettyxml(indent='  ')

    def save(self, dst_path):
        dst = open(dst_path, 'w')
        dst.write(self.__str__())

    def add_game_md5(self, title, md5):
        game = self._game(title)
        roms = game.find('roms')
        # If such a ROM already exists, there is no need to add it.
        if roms.find('./rom[@md5="' + md5 + '"]'):
            return

        rom = ET.SubElement(roms, 'rom')
        rom.set('md5', md5)

    def _game(self, title):
        """ Get a game from its title, create it if it doesn't exist.
        """
        game = self._get_game(title)
        if game is None:
            game = self._add_game(title)

        return game

    def _get_game(self, title):
        # FIXME What if title contains quotes?
        return self.games.find('./game[_title="' + title + '"]')

    def _add_game(self, title):
        game = ET.SubElement(self.games, 'game')
        titleE = ET.SubElement(game, '_title')
        titleE.text = title
        ET.SubElement(game, 'roms')

        return game

    def set_game_title(self, game, title):
        if not game in self.games:
            return

        for t in game.findall('_title'):
            game.remove(t)

        titleE = ET.SubElement(game, '_title')
        titleE.text = title

    def _sort(self):
        games = self.gameinfo.find('games')

        data = []
        for game in games:
            Gameinfo._sort_game_titles(game)
            Gameinfo._sort_game_roms(game)
            title = game.findtext('_title')
            data.append((title, game))

        data = sorted(data, key=lambda game: game[0])

        games[:] = [item[-1] for item in data]

    def _sort_game_titles(game):
        titles = game.findall('_title')

        data = {}
        for title in titles:
            data[title.text] = title
            game.remove(title)

        for title in sorted(data.keys()):
            game.append(data[title])

    def _sort_game_roms(game):
        roms = game.find('roms')

        keys = set()
        data = []
        for rom in roms:
            md5 = rom.get('md5')
            if not md5 in keys:
                data.append((md5, rom))
                keys.add(md5)

        data = sorted(data, key=lambda rom: rom[0])

        roms[:] = [item[-1] for item in data]
        game.remove(roms)
        game.append(roms)

    def _merge_games(self, game_a, game_b):
        if game_a is game_b:
            return
        for title in game_b.findall('_title'):
            game_a.append(title)
        roms = game_a.find('roms')
        for rom in game_b.findall('roms/rom'):
            roms.append(rom)
        if game_b in self.games:
            self.games.remove(game_b)

    def merge(self, others):
        for other in others:
            # Move all games in the document
            for game in other.games:
                self.games.append(game)

            # Merge games sharing ROMs
            game_for_rom = {}
            for game in self.games:
                for rom in game.findall('roms/rom'):
                    md5 = rom.attrib['md5']
                    if md5 in game_for_rom.keys():
                        game_for_rom[md5].append(game)
                    else:
                        game_for_rom[md5] = [ game ]
            for game in self.games:
                for rom in game.findall('roms/rom'):
                    md5 = rom.attrib['md5']
                    for duplicate in game_for_rom[md5]:
                        self._merge_games(game, duplicate)
                    game_for_rom[md5] = [ game ]

            # Merge games sharing titles
            game_for_title = {}
            for game in self.games:
                for title in game.findall('_title'):
                    if title.text in game_for_title.keys():
                        game_for_title[title.text].append(game)
                    else:
                        game_for_title[title.text] = [ game ]
            for game in self.games:
                for title in game.findall('_title'):
                    for duplicate in game_for_title[title.text]:
                        self._merge_games(game, duplicate)
                    game_for_title[title.text] = [ game ]

    def _unique_title(self, titles):
        games = []

        # Look for games having these titles
        for title in titles:
            for game in self.games.findall('game[_title=%s]' % _quote(title.text)):
                games.append(game)

        # If only one game as one of these titles and it has only one title, his title is unique.
        if len(games) is 1:
            titles = games[0].findall('_title')
            if len(titles) is 1:
                return titles[0].text

        return None

    def remove_unknown_titles(self, reference):
        for game in self.games_with_multiple_titles():
            titles = game.findall('_title')
            unique_title = reference._unique_title(titles)
            if unique_title:
                self.set_game_title(game, unique_title)

    def games_with_multiple_titles(self):
        games = []

        self._sort()
        for game in self.games:
            titles = game.findall('_title')
            if len(titles) is 1:
                continue
            if len(titles) is 0:
                # TODO error
                continue
            games.append(game)

        return games

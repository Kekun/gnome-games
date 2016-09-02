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

    def find(self, xpath):
        return self.gameinfo.find(xpath)

    def findall(self, xpath):
        return self.gameinfo.findall(xpath)

    def add_game_discs(self, title, disc_ids):
        """ Add a set of discs with their own IDs.
        """
        # If one of the discs already exists, do nothing.
        for disc_id in disc_ids:
            if self.games.find('./game/discs/disc[@id="' + disc_id + '"]'):
                print ("Disc " + disc_id + " already exists.")

                return

        game = self._game(title)
        discs_node = ET.SubElement(game, 'discs')

        for disc_id in disc_ids:
            disc_node = ET.SubElement(discs_node, 'disc')
            disc_node.set('id', disc_id)

        return discs_node

    def _game(self, title):
        """ Get a game from its title, create it if it doesn't exist.
        """
        game = self._get_game(title)
        if game is None:
            game = self._add_game(title)

        return game

    def _get_game(self, title):
        # FIXME Is this replacement working?
        title = title.replace('"', '&quot;')

        return self.games.find('./game[_title="%s"]' % title)

    def _add_game(self, title):
        game = ET.SubElement(self.games, 'game')
        titleE = ET.SubElement(game, '_title')
        titleE.text = title

        return game

    def get_game_for_disc_id(self, disc_id):
        return self.find('games/game/discs/disc[@id="' + disc_id + '"]/../..')

    def get_game_title(self, game):
        if not game in self.games:
            return

        title = game.find('_title')
        if title is None:
            return

        return title.text

    def get_game_disc_set_id(self, game):
        if not game in self.games:
            return

        disc = game.find('discs/disc[1]')
        if disc is None:
            return

        return disc.get('id')

    def set_game_title(self, game, title):
        if not game in self.games:
            return

        for t in game.findall('_title'):
            game.remove(t)

        titleE = ET.SubElement(game, '_title')
        titleE.text = title

    def set_game_controllers(self, game, controllers):
        if not game in self.games:
            return

        for c in game.findall('controllers'):
            game.remove(c)

        controllers_node = ET.SubElement(game, 'controllers')
        for controller in controllers:
            controller_node = ET.SubElement(controllers_node, 'controller')
            controller_node.set('type', controller)

    def set_disc_title_for_disc_id(self, disc_id, title):
        disc = self.find('games/game/discs/disc[@id="' + disc_id + '"]')
        if disc is None:
            return

        for t in disc.findall('_title'):
            disc.remove(t)

        titleE = ET.SubElement(disc, '_title')
        titleE.text = title

    def _sort(self):
        games = self.gameinfo.find('games')

        data = []
        for game in games:
            Gameinfo._sort_game_titles(game)
            Gameinfo._sort_game_discs(game)
            Gameinfo._sort_game_controllers(game)

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

    def _sort_game_discs(game):
        discs_nodes = game.findall('discs')

        keys = set()
        data = []
        for discs_node in discs_nodes:
            disc_node = discs_node.find('disc')
            if disc_node is None:
                continue
            disc_id = disc_node.get('id')
            if not disc_id in keys:
                data.append((disc_id, discs_node))
                keys.add(disc_id)

        data = sorted(data, key=lambda pair: pair[0])

        discs_nodes[:] = [item[-1] for item in data]
        for disc_id, discs_node in data:
            game.remove(discs_node)
            game.append(discs_node)

    def _sort_game_controllers(game):
        controllers_nodes = game.findall('controllers')

        for controllers_node in controllers_nodes:
            game.remove(controllers_node)
            game.append(controllers_node)

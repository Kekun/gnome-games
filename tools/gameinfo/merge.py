#!/bin/env python3

from gameinfo import Gameinfo
from sys import argv

def merge_missing_games(gameinfo, reference):
    games = gameinfo.find('games')
    reference_games = reference.find('games')
    for reference_game in reference.findall('games/game'):
        disc_id = reference.get_game_disc_set_id(reference_game)
        game = gameinfo.get_game_for_disc_id(disc_id)

        # If the game already exists in gameinfo, continue
        if game is not None:
            continue

        print('new game')

        reference_games.remove(reference_game)
        games.append(reference_game)

def merge_game_titles(gameinfo, reference):
    for game in gameinfo.findall('games/game'):
        disc_id = gameinfo.get_game_disc_set_id(game)
        reference_game = reference.get_game_for_disc_id(disc_id)

        # If the game is new, continue
        if reference_game is None:
            continue

        # If we didn't extract the info correctly in the reference,
        # there is nothing interesting to retrieve from it.
        disc_set = game.find('discs[@info]')
        reference_disc_set = reference_game.find('discs[@info]')
        if disc_set is None and reference_disc_set is not None:
            continue

        reference_title = reference.get_game_title(reference_game)
        if not reference_title:
            continue

        title = gameinfo.get_game_title(game)
        if title == reference_title:
            continue

        if disc_set is not None:
            del disc_set.attrib['info']

        gameinfo.set_game_title(game, reference_title)

def merge_disc_titles(gameinfo, reference):
    for reference_disc in reference.findall('games/game/discs/disc[_title]'):
        disc_id = reference_disc.get('id')
        title = reference_disc.find('_title').text
        gameinfo.set_disc_title_for_disc_id(disc_id, title)
        disc_set = gameinfo.find('games/game/discs/disc[@id="' + disc_id + '"]/..')
        attribs = disc_set.attrib
        if 'includes' in attribs.keys():
            del attribs['includes']

if __name__ == '__main__':
    if len(argv) < 4:
        exit(1)

    source_path = argv[1]
    reference_path = argv[2]
    out_path = argv[3]

    gameinfo = Gameinfo(source_path)
    reference = Gameinfo(reference_path)

    merge_missing_games(gameinfo, reference)
    merge_game_titles(gameinfo, reference)
    merge_disc_titles(gameinfo, reference)

    gameinfo.save(out_path)

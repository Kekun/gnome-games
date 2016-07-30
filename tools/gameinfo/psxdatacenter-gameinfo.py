#!/bin/env python3

from gameinfo import Gameinfo
from os import makedirs
from os.path import exists, realpath
import re
import requests

def _top_srcdir():
    return realpath(__file__ + '"/../../..')

def _downloaddir():
    return _top_srcdir() + '/tools/gameinfo/download'

def _outdir():
    return _top_srcdir() + '/tools/gameinfo/out'

def _fetch_page(url):
    user_agent = {'User-Agent': 'Gameinfo PlayStation DataCenter Scrapper 1.0'}
    response = requests.get(url, headers=user_agent)

    # Try to decode utf-16
    try:
        page = response.content.decode('utf-16')
        if page.startswith('<html'):
            return page
    except:
        pass

    return response.text

class GamesListScrapper:
    def _parse_game_list_page(page, gameinfo, verbose=True):
        skip = '.*?'
        grab = '(.*?)'

        begin = '<tr>' + skip
        end  = skip + '</tr>'

        info_part = 'col1' + skip + 'href="' + grab + '"'
        id_part = 'col2' + skip + '>' + grab + '</td>'
        title_part = 'col3' + skip + '>&nbsp;' + grab + '</td>'

        game_expr = begin + info_part + skip + id_part + skip + title_part + end

        domain = 'http://psxdatacenter.com/'

        for match in re.finditer(game_expr, page, re.DOTALL):
            comments = {
                'info': domain + match.group(1),
            }

            disc_ids = [disc_id.lower() for disc_id in match.group(2).split("<br>")]

            title = match.group(3).split('<br>')[0]
            title = title.split('&nbsp; -&nbsp;')[0]

            if '<u>Includes:</u>' in match.group(3):
                includes = match.group(3).split('<u>Includes:</u>')[1].replace('\n', ' ').replace('&nbsp;', ' ').replace('</span>', '')
                includes = re.sub('<span.*?>', '', includes)
                comments['includes'] = includes.strip()

            if verbose:
                print("Adding " + " ".join(disc_ids).upper() + ": " + title)

            gameinfo.add_game_discs(title, disc_ids, comments)

    def fetch_tmp_gameinfo():
        gameinfo = Gameinfo()

        game_lists = [
            'http://psxdatacenter.com/jlist.html',
            'http://psxdatacenter.com/plist.html',
            'http://psxdatacenter.com/ulist.html']

        for url in game_lists:
            page = _fetch_page(url)
            GamesListScrapper._parse_game_list_page(page, gameinfo)

        return gameinfo

class GamePageScrapper:
    def _get_game_title(game_page):
        title_search = 'Official Title.*?<td.*?>(?:&nbsp;)*(.*?)</td>'
        match = re.search(title_search, game_page, re.DOTALL)
        if not match:
            return None

        title = match.group(1)

        title = title.replace('&nbsp;', ' ')
        title = title.strip()

        return title

    def parse_game_page(gameinfo, game, url):
        game_page = _fetch_page(url)

        title = GamePageScrapper._get_game_title(game_page)
        if not title:
            return

        print(title)

        gameinfo.set_game_title(game, title)

class Scrapper:
    _FILENAME = 'playstation.gameinfo.xml.in'
    _TMP_FILENAME = _FILENAME + '.tmp'

    def _get_tmp_gameinfo():
        gameinfo_path = _outdir() + '/' + 'playstation.gameinfo.xml.in.tmp'
        if exists(gameinfo_path):
            return Gameinfo(gameinfo_path)

        gameinfo = GamesListScrapper.fetch_tmp_gameinfo()

        if not exists(_outdir()):
            makedirs(_outdir())

        gameinfo.save(gameinfo_path)

        return gameinfo

    def scrap():
        gameinfo = Scrapper._get_tmp_gameinfo()

        gameinfo_path = _outdir() + '/' + 'playstation.gameinfo.xml.in.tmp'
        if not exists(_outdir()):
            makedirs(_outdir())

        changed = False
        i = 0
        for game in gameinfo.findall('games/game'):
            for discs in game.findall('./discs[@info]'):
                info = discs.get('info')
                if not info:
                    continue

                GamePageScrapper.parse_game_page(gameinfo, game, info)
                changed = True

                del discs.attrib['info']

                i = i + 1
                if i >= 10:
                    gameinfo.save(gameinfo_path)
                    i = 0
        if changed:
            gameinfo.save(gameinfo_path)

if __name__ == '__main__':
    Scrapper.scrap()

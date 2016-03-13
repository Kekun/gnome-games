#!/bin/env python3

from gameinfo import Gameinfo
import re
import xml.etree.ElementTree as ET

def gameinfo_from_tosec(xmls):
    datafiles = []
    for xml in xmls:
        datafiles.append(ET.fromstring(xml))

    return _gameinfo_from_tosec(datafiles)

#def gameinfo_from_tosec_string(xml):
#    datafile = ET.fromstring(xml)

#    return _gameinfo_from_tosec([datafile])

#def gameinfo_from_tosec_file(filename):
#    tosec = ET.parse(filename)
#    datafile = tosec.getroot()

#    return _gameinfo_from_tosec([datafile])

def _gameinfo_from_tosec(datafiles):
    gameinfo = Gameinfo()

    title_pattern = '\s*(.*?)\s*'
    revision_pattern = '\s+(?:Rev\s+[\w-]+|v[\w.]+)?\s*' # Optional
    parentheses_pattern = '\(.*\)'
    brackets_pattern = '(?:[;*])?' # Optional
    pattern = title_pattern + revision_pattern + parentheses_pattern + brackets_pattern
    title_re = re.compile(pattern)

    for datafile in datafiles:
        for game in datafile.iter('game'):
            rom = game.find('rom')
            name = game.attrib['name']
            md5 = rom.attrib['md5']
            title = name
            title_match = title_re.search(name)
            if title_match:
                title = title_match.group(1)
            gameinfo.add_game_md5(title, md5)

    return gameinfo

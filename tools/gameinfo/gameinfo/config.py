#!/bin/env python3

from gameinfo import Gameinfo
from os.path import exists, dirname, realpath
import configparser

def parse_config_file(config_file):
    config = configparser.ConfigParser()
    config.read(config_file)

    if not 'Gameinfo' in config:
        return None

    system = config['Gameinfo']['System']

    if system is None:
        return None

    gameinfo_path = dirname(realpath(config_file)) + '/' + system + '.gameinfo.xml.in'

    gameinfo = None
    if exists(gameinfo_path):
        gameinfo = Gameinfo(gameinfo_path)

    return (config, system, gameinfo_path, gameinfo)

def parse_config_files(config_files):
    result = []
    for config_file in config_files:
        parsed = parse_config_file(config_file)
        if parsed:
            result.append(parsed)

    return result

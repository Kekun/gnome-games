#!/bin/env python3

from gameinfo import Gameinfo
from sys import argv

if __name__ == '__main__':
    if len(argv) > 1:
        for gameinfo_path in argv[1:]:
            gameinfo = Gameinfo(gameinfo_path)
            gameinfo.save(gameinfo_path)

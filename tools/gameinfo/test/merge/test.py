#!/bin/env python3

from gameinfo import Gameinfo

a = Gameinfo('test/merge/a.gameinfo.xml.in')
b = Gameinfo('test/merge/b.gameinfo.xml.in')
a.merge([b])
a.save('test/merge/result.gameinfo.xml.in')
print(a)

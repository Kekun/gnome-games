#!/bin/env python3

from os import makedirs, walk
from os.path import basename, dirname, exists, isfile, realpath
from zipfile import ZipFile
import re
import requests
import tosec.datpack
import tosec.gameinfo

def _top_srcdir():
    return realpath(__file__ + '"/../../../..')

def _downloaddir():
    return _top_srcdir() + '/tools/gameinfo/download'

def _outdir():
    return _top_srcdir() + '/tools/gameinfo/out'

def _tosec_outdir():
    return _outdir() + '/tosec-gameinfo'

class DatpackManager:
    def most_recent_datpack():
        """Get the path of the most recent datpack, download it if needed.
        """
        datpack_filepath = None
        try:
            datpack_url = DatpackManager._most_recent_datpack_url()

            datpack_filename = datpack_url.split(':')[-1] + '.zip'
            datpack_filepath = _downloaddir() + '/' + datpack_filename

            if isfile(datpack_filepath):
                print(datpack_filename + ' is up-to-date.')
            else:
                print('Downloading ' + datpack_filename + '...')
                DatpackManager._download(datpack_url, datpack_filepath)

            return Datpack(datpack_filepath)
        except:
            datpack_filepath = DatpackManager._most_recent_datpack_file(_downloaddir())

        if datpack_filepath is None:
            return None

        return Datpack(datpack_filepath)

    def _most_recent_datpack_url():
        """Get the URL of the most recent datpack.
        """
        tosec = 'http://www.tosecdev.org'
        downloads = '/downloads/category/22-datfiles'

        # Assumes the first url links to the most recent file
        response = requests.get(tosec + downloads)
        download = re.search('/downloads/category/\d+-\d+-\d+-\d+', response.text)
        if download is None:
            return None

        download = download.group(0)

        response = requests.get(tosec + download)
        datpack = re.search(download + '\?download=.+?v\d+-\d+-\d+', response.text)
        if datpack is None:
            return None

        return tosec + datpack.group(0)

    def _download(url, path):
        """Download url into path.
        """
        if isfile(path):
            return False

        download_dir = dirname(path)
        if not exists(download_dir):
            makedirs(download_dir)

        response = requests.get(url)
        destination = open(path, 'wb')
        destination.write(response.content)
        destination.close()

        return True

    def _most_recent_datpack_file(directory):
        most_recent = None

        for d in walk(directory):
            for f in d[2]:
                if most_recent is None or basename(most_recent) < f:
                    most_recent = d[0] + '/' + f

        return most_recent

class Datpack:
    def __init__(self, datpack_filepath):
        self.filepath = datpack_filepath
        self.zip = ZipFile(datpack_filepath, 'r')

    def _get_datafiles(self, system_names):
        """Get datafile names in datpack_zip correspind to system_names.
        """
        files = []
        for system_name in system_names:
            if system_name is '':
                continue

            filename_re = re.compile('TOSEC/' + system_name + '.*\.dat')
            for filename in self.zip.namelist():
                if filename_re.match(filename):
                    files.append(filename)

        return files

    def _get_gameinfo_from_datpack(self, system_names):
        """Get a gameinfo for datafiles in datpack_zip correspind to
        system_names.
        """
        xmls = []
        for filename in self._get_datafiles(system_names):
            datafile = self.zip.open(filename)
            xmls.append(datafile.read())

        return tosec.gameinfo.gameinfo_from_tosec(xmls)

def get_gameinfo(datpack, system, system_names):
    if datpack is None:
        return

    if not exists(_tosec_outdir()):
        makedirs(_tosec_outdir())

    print('Extracting ' + system + ' gameinfo...')
    gameinfo = datpack._get_gameinfo_from_datpack(system_names)
    gameinfo_path = _tosec_outdir() + '/' + system + '.gameinfo.xml.in'
    gameinfo.save(gameinfo_path)

    return gameinfo_path

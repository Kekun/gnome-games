#!/bin/env python3

from os import makedirs
from os.path import dirname, exists, isfile, realpath
#import re
#import requests
import xml.etree.ElementTree as ET

#def _top_srcdir():
#    return realpath(__file__ + '"/../../../..')

#def _downloaddir():
#    return _top_srcdir() + '/tools/gameinfo/download'

#def _outdir():
#    return top_srcdir() + '/tools/gameinfo/out'

#def _tosec_outdir():
#    return _outdir() + '/tosec-gameinfo'

#class DatpackManager:
#    def most_recent_datpack():
#        """Get the path of the most recent datpack, download it if needed.
#        """
#        datpack_url = _most_recent_datpack_url()
#        if datpack_url is None:
#            return  None

#        datpack_filename = datpack_url.split(':')[-1] + '.zip'
#        datpack_filepath = _downloaddir() + '/' + datpack_filename

#        if isfile(datpack_filepath):
#            print(datpack_filename + ' is up-to-date.')
#        else:
#            print('Downloading ' + datpack_filename + '...')
#            _download(datpack_url, datpack_filepath)

#        return datpack_filepath

#    def _most_recent_datpack_url():
#        """Get the URL of the most recent datpack.
#        """
#        tosec = 'http://www.tosecdev.org'
#        downloads = '/downloads/category/22-datfiles'

#        # Assumes the first url links to the most recent file
#        response = requests.get(tosec + downloads)
#        download = re.search('/downloads/category/\d+-\d+-\d+-\d+', response.text)
#        if download is None:
#            return None

#        download = download.group(0)

#        response = requests.get(tosec + download)
#        datpack = re.search(download + '\?download=.+?v\d+-\d+-\d+', response.text)
#        if datpack is None:
#            return None

#        return tosec + datpack.group(0)

#    def _download(url, path):
#        """Download url into path.
#        """
#        if isfile(path):
#            return False

#        download_dir = dirname(path)
#        if not exists(download_dir):
#            makedirs(download_dir)

#        response = requests.get(url)
#        destination = open(path, 'wb')
#        destination.write(response.content)
#        destination.close()

#        return True

#def _get_datafiles(datpack_zip, system_names):
#    """Get datafile names in datpack_zip correspind to system_names.
#    """
#    files = []
#    for system_name in system_names:
#        if system_name is '':
#            continue

#        filename_re = re.compile('TOSEC/' + system_name + '.*\.dat')
#        for filename in datpack_zip.namelist():
#            if filename_re.match(filename):
#                files.append(filename)

#    return files

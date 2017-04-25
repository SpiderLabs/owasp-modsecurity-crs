#!/usr/bin/env python

"""
usage: upgrade.py [-h] [--crs] [--geoip] [--cron] [--quiet]

Install upgrades to the ModSecurity CRS and/or GeoIP country database.

Run util/upgrade.py -h for explanation and examples.
"""

from __future__ import unicode_literals
from __future__ import print_function
import argparse
import os
import random
import subprocess
from subprocess import check_output, STDOUT, CalledProcessError
import sys
import time
import zlib

try:
    from urllib.request import urlopen # Python 3
except ImportError:
    from urllib2 import urlopen        # Python 2

def upgrade_crs(crs_directory, quiet):
    """Upgrade the CRS using Git. Assumes the CRS is a local Git repo."""

    git_directory = os.path.join(crs_directory, '.git')
    if not os.path.isdir(git_directory):
        raise Exception('Not a git repository: ' + crs_directory)

    # Do a git 'git pull'
    os.chdir(crs_directory)
    gitcmd = "git pull origin HEAD --ff-only"
    try:
        git_output = check_output(gitcmd, stderr=STDOUT, shell=True)        
        returncode = 0
    except CalledProcessError as ex:
        git_output = ex.output
        returncode = ex.returncode
    if returncode != 0:
        raise Exception ("Git pull failed! Error: " + git_output)
    if not quiet:
        print('crs:')
        print(git_output.decode('utf-8'))

    # Could be improved. We're not supposed to parse 'git pull' output.
    changed = False if b'Already up-to-date' in git_output else True
    return changed

def upgrade_geoip(crs_directory, quiet):
    """
    Upgrade MaxMind GeoIP database by fetching from maxmind.com.
    Download page: http://dev.maxmind.com/geoip/legacy/geolite/
    This product includes GeoLite data created by MaxMind, available from
    http://www.maxmind.com.
    """
    url = 'https://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz'
    db_directory = os.path.join(crs_directory, 'util', 'geo-location')
    db_name = os.path.join(db_directory, 'GeoIP.dat')

    if not os.path.isdir(db_directory):
        raise Exception('Database directory not found: ' + db_directory)

    # Fetch GeoIP.dat.gz from HTTPS into memory
    response = urlopen(url)
    db_gzipped = response.read()
    if not db_gzipped:
        raise Exception('Empty response from ' + url)

    # Uncompress gzip stream
    db_contents = zlib.decompress(db_gzipped, zlib.MAX_WBITS | 32)

    # Check if database content is changed from existing file
    # If not changed, return the status to the caller and skip overwriting
    old_db_contents = ""
    if os.path.isfile(db_name):
        with open(db_name, 'rb') as db_file:
            old_db_contents = db_file.read()

    # zlib returns a byte string, therefore we must cast old_db_contents to str
    old_db_contents = str(old_db_contents)
    if db_contents == old_db_contents:
        if not quiet:
            print('geoip:')
            print('Already up-to-date.')
        return False

    # Write uncompressed stream to tempfile
    tmp_file_name = db_name + '.tmp'
    with open(tmp_file_name, 'wb') as tmp_file:
        tmp_file.write(db_contents)

    # Atomically replace GeoIP.dat
    os.rename(tmp_file_name, db_name)

    if not quiet:
        print('geoip:')
        print('Downloaded ' + db_name + '.')
    return True

def parse_args():
    """
    Parse our inputs including help and support messages to guide the user.
    Returns an argparse object that can be used to access results
    """
    # Our constants for help
    returns_val = """
If you schedule this script via cron or similar, please add the --cron option
to insert a random delay and prevent hammering the upgrade servers.

Return value:
  Success if updates were applied
  Failure if no updates were available or an error occurred
    """
    examples = """
Example:
  util/upgrade.py --crs
  util/upgrade.py --geoip
  util/upgrade.py --crs --geoip
  util/upgrade.py --crs --quiet && apachectl configtest && apachectl restart
    """

    # When changing command line parameters, please remind to update:
    # (1) the __doc__ comment, (2) the examples above.
    parser = argparse.ArgumentParser(
        description = 'Install upgrades to the ModSecurity CRS and/or GeoIP country database.',
        epilog = returns_val+examples,
        formatter_class = argparse.RawTextHelpFormatter)
    parser.add_argument('--crs',
        action = 'store_true',
        help = 'Upgrade the CRS using Git')
    parser.add_argument('--geoip',
        action = 'store_true',
        help = 'Upgrade the MaxMind GeoLite Country database from maxmind.com')
    parser.add_argument('--cron',
        action = 'store_true',
        help = 'Randomly sleep 0-3 minutes before upgrading; use from cron')
    parser.add_argument('--quiet',
        action = 'store_true',
        help = 'Be quiet unless an error occurred')
    args = parser.parse_args()
    return args

def main():
    """
    The main function that handles kicking off all the functionality.
    It returns to the system 1 if failed or no updates were done, otherwise 0.
    """

    _max_sleep_mins = 3
    args = parse_args()
    if not (args.crs or args.geoip):
        print(__doc__)
        sys.exit(1)

    crs_directory = os.path.realpath(os.path.join(sys.path[0], '..'))
    if not os.path.isdir(crs_directory):
        raise Exception('Cannot determine CRS directory: ' + crs_directory)

    # If --cron supplied, sleep 0-3 minutes to be nice to upstream servers
    if args.cron:
        secs = random.randint(0, _max_sleep_mins*60)
        time.sleep(secs)

    changed = False

    if args.crs:
        try:
            crs_changed = upgrade_crs(crs_directory, args.quiet)
            changed = changed or crs_changed
        except Exception as e:
            print('crs:', e)

    if args.geoip:
        try:
            geoip_changed = upgrade_geoip(crs_directory, args.quiet)
            changed = changed or geoip_changed
        except Exception as e:
            print('geoip:', e)

    # Set process error value: if something was upgraded, return success
    # This allows idioms like: upgrade.py --crs && apachectl restart
    sys.exit(0 if changed else 1)


if __name__ == "__main__":
    main()

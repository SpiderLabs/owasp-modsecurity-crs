#!/usr/bin/env python

"""
Install upgrades to the ModSecurity CRS and/or GeoIP country database.

Usage: util/upgrade.py [--cron] [--quiet] [crs] [geoip]
    crs:        Upgrade the CRS using Git
    geoip:      Upgrade the MaxMind GeoLite Country database from maxmind.com
    --cron:     Randomly sleep 0-3 minutes before downloading, use from cron
    --quiet:    Be quiet unless an error occurred

Return value:
    Success if something was updated
    Failure if no updates were done or an error occurred

Example:
    util/upgrade.py crs
    util/upgrade.py geoip
    util/upgrade.py crs geoip
    util/upgrade.py --cron --quiet crs && apachectl configtest && apachectl restart
"""

import os, random, string, subprocess, sys, time, zlib

try:
    from urllib.request import urlopen # Python 3
except ImportError:
    from urllib2 import urlopen        # Python 2

def upgrade_crs(crs_directory, quiet):
    """Upgrade the CRS using Git. Assumes the CRS is a local Git repo."""

    git_directory = os.path.join(crs_directory, '.git')
    if not os.path.isdir(git_directory):
        raise Exception('crs: Not a git repository: ' + crs_directory)

    # Do a git 'git pull'
    os.chdir(crs_directory)
    git_output = subprocess.check_output(['git', 'pull', '--ff-only'])
    if not quiet:
        print('crs:')
        print(git_output.decode('utf-8'))

    # Could be improved. We're not supposed to parse 'git pull' output.
    changed = False if b'Already up-to-date' in git_output else True
    return changed

def upgrade_geoip(crs_directory, quiet):
    """Upgrade MaxMind GeoIP database by fetching from maxmind.com.
    Download page: http://dev.maxmind.com/geoip/legacy/geolite/
    This product includes GeoLite data created by MaxMind, available from
    http://www.maxmind.com."""
    url = 'https://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz'
    db_directory = os.path.join(crs_directory, 'util', 'geo-location')
    db_name = os.path.join(db_directory, 'GeoIP.dat')

    if not os.path.isdir(db_directory):
        raise Exception('geoip: Database directory not found: ' + db_directory)

    # Fetch GeoIP.dat.gz from HTTPS into memory
    response = urlopen(url)
    db_gzipped = response.read()
    if not db_gzipped:
        raise Exception('geoip: Empty response from ' + url)

    # Uncompress gzip stream
    db = zlib.decompress(db_gzipped, zlib.MAX_WBITS | 32)

    # Check if database content is changed from existing file
    # If not changed, return the status to the caller and skip overwriting
    old_db = ''
    if os.path.isfile(db_name):
        with open(db_name, 'rb') as db_file:
            old_db = db_file.read()

    if db == old_db:
        if not quiet:
            print('geoip:')
            print('Already up-to-date.')
        return False

    # Write uncompressed stream to tempfile
    tmp_file_name = db_name + '.tmp'
    with open(tmp_file_name, 'wb') as tmp_file:
        tmp_file.write(db)

    # Atomically replace GeoIP.dat
    os.rename(tmp_file_name, db_name)

    if not quiet:
        print('geoip:')
        print('Downloaded ' + db_name + '.')
    return True

# Parse arguments
flag_upgrade_crs   = 'crs' in sys.argv
flag_upgrade_geoip = 'geoip' in sys.argv
flag_quiet         = '--quiet' in sys.argv
flag_cron          = '--cron' in sys.argv
flag_help          = '--help' in sys.argv or '-h' in sys.argv
if flag_help or not (flag_upgrade_crs or flag_upgrade_geoip):
    print(__doc__)
    sys.exit(1)

# Initialize variables
changed = False
crs_directory = os.path.realpath(os.path.join(sys.path[0], '..'))
if not os.path.isdir(crs_directory):
    raise Exception('Cannot determine CRS directory: ' + crs_directory)

# If --cron supplied, sleep 0-3 minutes to be nice to upstream servers
if flag_cron:
    secs = random.randint(0, 180)
    time.sleep(secs)

if flag_upgrade_crs:
    changed = changed or upgrade_crs(crs_directory, flag_quiet)

if flag_upgrade_geoip:
    changed = changed or upgrade_geoip(crs_directory, flag_quiet)

# Set process error value: if something was upgraded, return success
# This allows idioms like: ./upgrade.py crs geoip && apachectl restart
sys.exit(0 if changed else 1)

from ftw import ruleset, logchecker, testrunner
import datetime
import pytest
import pdb
import sys
import re
import os
import config

def test_crs(ruleset, test, logchecker_obj):
    runner = testrunner.TestRunner()
    for stage in test.stages:
        runner.run_stage(stage, logchecker_obj)
        
class FooLogChecker(logchecker.LogChecker):
    
    def reverse_readline(self, filename):
        with open(filename) as f:
            f.seek(0, os.SEEK_END)
            position = f.tell()
            line = ''
            while position >= 0:
                f.seek(position)
                next_char = f.read(1)
                if next_char == "\n":
                    yield line[::-1]
                    line = ''
                else:
                    line += next_char
                position -= 1
            yield line[::-1]

    def get_logs(self):
        log_location = config.log_location_linux
        log_date_regex = config.log_date_regex
        log_date_format = config.log_date_format
        pattern = re.compile(r'%s' % log_date_regex)
        our_logs = []
        for lline in self.reverse_readline(log_location):
            # Extract dates from each line
            match = re.match(pattern, lline)
            if match:
                log_date = match.group(1)
                # Convert our date
                log_date = datetime.datetime.strptime(log_date, log_date_format)
                # NGINX doesn't give us microsecond level detail, truncate.
                if log_location == "/usr/local/nginx/logs/error.log":
                    ftw_start = self.start.replace(microsecond=0)
                else:
                    ftw_start = self.start
                ftw_end = self.end
                # If we have a log date in range
                if log_date <= ftw_end and log_date >= ftw_start:
                    our_logs.append(lline)
                # If our log is from before FTW started stop
                if log_date < ftw_start:
                    break
        return our_logs
@pytest.fixture
def logchecker_obj():
    return FooLogChecker()

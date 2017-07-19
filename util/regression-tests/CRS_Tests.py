from ftw import ruleset, logchecker, testrunner
import pytest
import pdb
import sys
import re
import os
import ConfigParser

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
        import datetime
        config = ConfigParser.ConfigParser()
        settings_file = os.path.abspath(os.path.dirname(os.path.dirname(__file__))) + '/settings.ini'
        print('%s settings file location' % settings_file)
        config.read(settings_file)
        log_location = config.get('settings', 'log_location')
        our_logs = []
        pattern = re.compile(r"\[([A-Z][a-z]{2} [A-z][a-z]{2} \d{1,2} \d{1,2}\:\d{1,2}\:\d{1,2}\.\d+? \d{4})\]")
        for lline in self.reverse_readline(log_location):
            # Extract dates from each line
            match = re.match(pattern,lline)
            if match:
                log_date = match.group(1)
                # Convert our date
                log_date = datetime.datetime.strptime(log_date, "%a %b %d %H:%M:%S.%f %Y")
                ftw_start = self.start
                ftw_end = self.end
                # If we have a log date in range
                if log_date <= ftw_end and log_date >= ftw_start:
                    our_logs.append(lline)
                # If our log is from before FTW started stop
                if(log_date < ftw_start):
                    break
        return our_logs
@pytest.fixture
def logchecker_obj():
    return FooLogChecker()

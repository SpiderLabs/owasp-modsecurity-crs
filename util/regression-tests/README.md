owasp-crs-regressions
=====================

Introduction
============
Welcome to the OWASP Core Rule Set regression testing suite. This suite is meant to test specific rules in OWASP CRS version 3. The suite is designed to uses preconfigured IDs that are specific to this version of CRS. The tests themselves can be run without CRS and one would expect the same elements to be blocked, however one must override the default Output parameter in the tests. 

Run tests using Docker
======================

This is a simple self-contained way to run the tests against the currently checked out repo, without having to separately have to set up a test web server with ModSecurity or any of the test framework tools on your real dev machine. If you use this approach, you will not need to do any of the other below installation and run steps.

First build the container image. You only needed to do once. You do not need to rebuild the image between changes to CRS files in this repo, as you will be mounting the repo directly when you run the container.
```
docker build --tag crsregressiontests .
```

Running tests:
```
# Run all tests
docker run -it --rm -v `realpath ../../`:/etc/modsecurity/owasp-crs crsregressiontests

# Run a single test file
docker run -it --rm -v `realpath ../../`:/etc/modsecurity/owasp-crs crsregressiontests py.test -vs util/regression-tests/CRS_Tests.py --rule=util/regression-tests/tests/REQUEST-942-APPLICATION-ATTACK-SQLI/942320.yaml

# Run a shell from which you can also run the test and troubleshoot log files, etc.:
docker run -it --rm -v `realpath ../../`:/etc/modsecurity/owasp-crs crsregressiontests bash
```

Installation
============
The OWASP Core Rule Set project was part of the effort to develop FTW, the Framework for Testing WAFs. As a result, we use this project in order to run our regression testing. FTW is designed to use existing Python testing frameworks to allow for easy to read web based testing, provided in YAML. You can install FTW by from the repository (at https://github.com/CRS-support/ftw) or by running pip.

```pip install -r requirements.txt```

This will install FTW as a library. It can also be run natively, see the FTW documentation for more detail.

Requirements
============
There are Three requirements for running the OWASP CRS regressions.

1. You must have ModSecurity specify the location of your error.log, this is done in the config.py file
2. ModSecurity must be in DetectionOnly (or anomaly scoring) mode
3. You must disable IP blocking based on previous events

Note: The test suite compares timezones -- if your test machine and your host machine are in different timezones this can cause bad results

To accomplish 2. and 3. you may use the following rule in your setup.conf:

```
SecAction "id:900005,\
  phase:1,\
  nolog,\
  pass,\
  ctl:ruleEngine=DetectionOnly,\
  ctl:ruleRemoveById=910000,\
  setvar:tx.paranoia_level=4,\
  setvar:tx.crs_validate_utf8_encoding=1,\
  setvar:tx.arg_name_length=100,\
  setvar:tx.arg_length=400"
```

Once these requirements have been met the tests can be run by using pytest.

Running The Tests
=================

On Windows this will look like:
-------------------------------
Single Rule File:
```py.test.exe -v CRS_Tests.py --rule=tests/test.yaml```
The Whole Suite:
```py.test.exe -v CRS_Tests.py --ruledir_recurse=tests/```

On Linux this will look like:
-----------------------------
Single Rule File:
```py.test -v CRS_Tests.py --rule=tests/test.yaml```
The Whole Suite:
```py.test -v CRS_Tests.py --ruledir_recurse=tests/```

Contributions
=============

We'd like to thank Fastly for their help and support in developing these tests.

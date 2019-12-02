from __future__ import print_function
import pytest
import os
import sys

def get_file_list(start):
    """
    Gets the file list of all files that end in .conf
    """
    valid_files = []
    for root, dirs, files in os.walk(start):
        for name in files:
            if name[-5:] == ".conf":
                valid_files.append(os.path.join(root,name))
    return valid_files
                           

def test_trailing_whitespace():
    """
    Test to ensure that there is no line with trailing whitespace
    """
    test_failed = False
    files = get_file_list(".")
    for fname in files:
        with open(fname,'r') as fp:
            for i,line in enumerate(fp):
                if len(line) > 1 and line[-2] == ' ':
                    print("Line", i+1, "in", fname, "has trailing whitespace.")
                    test_failed = True
    assert test_failed == False

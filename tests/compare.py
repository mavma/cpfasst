#!/usr/bin/env python3

import argparse
import sys
import glob
import os
import filecmp
import fnmatch
import subprocess

# patterns of files to ignore
ignore_files = ['*.json']


def check_path(path):
    try:
        proc_paths = glob.glob(path + '/Proc_*')
        assert len(proc_paths) == int(path[-3:])
        for proc_path in proc_paths:
            assert glob.glob(proc_path + '/*.dat')  # at least one dat file
    except:
        print(path + ' is not a valid path to LibPFASST output')
        sys.exit(1)


def find_mismatched_files(dir1, dir2):
    results = []
    contents = os.listdir(dir1)
    for item in contents:
        path1 = os.path.join(dir1, item)
        path2 = os.path.join(dir2, item)
        if os.path.isdir(path1):
            results += find_mismatched_files(path1, path2)
        else:
            if not filecmp.cmp(path1, path2, shallow=False):
                results.append(path1)
    return results


# Compares two top-level result dirs ("outdirP0001")
def compare_results(dir1, dir2, show_diff=False):
    check_path(dir1)
    check_path(dir2)
    print('Comparing results in directories:\n   {}\n   {}'.format(dir1, dir2))

    mismatched = find_mismatched_files(dir1, dir2)
    bad_files = []
    for pattern in ignore_files:
        bad_files += [item for item in mismatched if item not in fnmatch.filter(mismatched, pattern)]

    if bad_files:
        bad_files = [os.path.relpath(file, dir1) for file in bad_files]
        if show_diff:
            for file in bad_files:
                print('Difference in file ' + file)
                diff = subprocess.run(['diff', os.path.join(dir1, file), os.path.join(dir2, file)],
                                      capture_output=True, text=True)
                print(diff.stdout)
        else:
            print('Found differences in files:\n   ' + '\n   '.join(bad_files))
        sys.exit(1)
    else:
        print('Results are equal')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Compare the outputs of two runs of a LibPFASST example')
    parser.add_argument('dir1')
    parser.add_argument('dir2')
    parser.add_argument('--show-diff', action='store_true', help='show diff for mismatched files')
    args = parser.parse_args()

    compare_results(args.dir1, args.dir2, args.show_diff)








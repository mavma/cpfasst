#!/usr/bin/env python3
import argparse
import subprocess
from os import path
import shutil
import importlib
import sys

ALL_NML = ['probin.nml', 'sdc.nml', 'multi_level.nml', 'pipeline.nml']
CPF_EXAMPLES_PATH = './examples/'
LPF_TUTORIALS_PATH = './LibPFASST/Tutorials/'
OUTDIR_PREFIX = 'outdir'


def mpiexec(command, np, extra_args=None, cwd=None):
    shell_cmd = ['mpiexec', '-n', str(np)] + ([extra_args] if extra_args else []) + command
    try:
        subprocess.run(shell_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=cwd, check=True, text=True)
    except subprocess.CalledProcessError as e:
        exit('mpiexec run failed \n' +
             '   command: {}\n'.format(' '.join(e.cmd)) +
             '   cwd: {}\n'.format(path.abspath(cwd if cwd else '')) +
             '   return code: {}\n'.format(e.returncode) +
             e.output)


class GenericExampleRun:
    def __init__(self, cwd, exe, nml):
        for file in [exe, nml]:
            if not path.isfile(file):
                exit('File not found: ' + file + ' (did you forget to compile it first?)')
        self.cwd = cwd
        self.exe_relpath = path.relpath(exe, start=cwd)
        self.nml_relpath = path.relpath(nml, start=cwd)
        self.extra_args = []

    def run(self, np, mpiexec_extra_args=None):
        dat_dir = path.join(self.cwd, 'dat')
        if path.isdir(dat_dir):  # remove results dir if exists
            shutil.rmtree(dat_dir)
        output_dir = path.join(dat_dir, OUTDIR_PREFIX + 'P' + str(np).zfill(4))
        command = ['./' + self.exe_relpath, self.nml_relpath] + self.extra_args
        mpiexec(command, np, extra_args=mpiexec_extra_args, cwd=self.cwd)
        if not path.isdir(output_dir):
            exit('Something went wrong: run was successful but did not produce expected output directory')
        return output_dir


class CPFExampleRun(GenericExampleRun):
    def __init__(self, example, nml):
        example_dir = path.join(CPF_EXAMPLES_PATH, example)
        example_exe = path.join(example_dir, 'main')
        nml_path = path.join(LPF_TUTORIALS_PATH, example, nml)
        super().__init__(example_dir, example_exe, nml_path)


class LPFTutorialRun(GenericExampleRun):
    def __init__(self, example, nml):
        example_dir = path.join(LPF_TUTORIALS_PATH, example)
        example_exe = path.join(example_dir, 'main.exe')
        nml_path = path.join(LPF_TUTORIALS_PATH, example, nml)
        super().__init__(example_dir, example_exe, nml_path)
        self.extra_args = ['outdir="{}"'.format(OUTDIR_PREFIX)]


def test_and_run(example, mpiexec_args=None, np=1, nml_list=ALL_NML):
    print('Testing example {} with {} processor(s)'.format(example, np))
    compare = importlib.import_module('compare')
    for nml in nml_list:
        print('\nInput file: ' + nml)
        cpf = CPFExampleRun(example, nml)
        lpf = LPFTutorialRun(example, nml)
        print('Running cpfasst...', end='', flush=True)
        cpf_out = cpf.run(np, mpiexec_args)
        print(' Done')
        print('Running LibPFASST...', end='', flush=True)
        lpf_out = lpf.run(np, mpiexec_args)
        print(' Done')
        compare.compare_results(cpf_out, lpf_out, show_diff=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Convenience script for testing that output of cpfasst example matches equivalent LibPFASST tutorial.',
        epilog='WARNING: Deletes existing test results. Must be invoked from cpfasst project root.')
    parser.add_argument('example', help='Name of the example, e.g. "EX2_Dahlquist"')
    parser.add_argument('--np', help='Number of processors for parallel run (default: 1)', type=int, default=1)
    parser.add_argument('--input', help='Run for a specific nml file e.g. "probin.nml" (default: run for all)',
                        action='append', default=ALL_NML)
    parser.add_argument('--mpiargs', help='Additional arguments to mpiexec command')
    args = parser.parse_args()

    print('Python version ' + sys.version.replace('\n', ''))

    test_and_run(args.example, args.mpiargs, args.np, args.input)

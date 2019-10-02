#!/usr/bin/env python
import argparse
import json
import os
import shutil
import subprocess
import sys

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))


class PackageConfigPatcher:
    def __init__(self, suffix=''):
        self._suffix = suffix
        self._config_path = os.path.join(ROOT_DIR, 'package.json')
        self._orig_config = ''

    def __enter__(self):
        with open(self._config_path, 'r') as f:
            self._orig_config = f.read()
        patched_config = self._create_patched_config(self._orig_config)
        with open(self._config_path, 'w') as f:
            f.write(patched_config)

    def __exit__(self, exc_type, exc_value, traceback):
        with open(self._config_path, 'w') as f:
            f.write(self._orig_config)

    def _create_patched_config(self, config):
        patched_config = json.loads(config)
        if self._suffix:
            patched_config[
                'version'] = patched_config['version'] + '-' + self._suffix
        return json.dumps(patched_config, indent=2)


def parse_args():
    arg_parser = argparse.ArgumentParser()

    arg_parser.add_argument(
        '--dry-run', action='store_true', help='Dry run mode for npm publish')
    arg_parser.add_argument(
        '--tag', '-T', type=str, required=True, help='NPM published tag')
    arg_parser.add_argument(
        'dist_tar_file', action='store', help='dist.tgz created from CI')

    args = arg_parser.parse_args()
    if not args.dist_tar_file:
        arg_parser.print_help()
        sys.exit(1)
    return args


def main():
    args = parse_args()

    workdir = os.path.join(ROOT_DIR, 'build', 'publish')
    if not os.path.exists(workdir):
        os.makedirs(workdir)
    distdir = os.path.join(ROOT_DIR, 'dist')
    dryrun = '--dry-run' if args.dry_run else ''

    print('\n\n========== Publish standard package ==========')
    with PackageConfigPatcher(''):
        if os.path.exists(distdir):
            shutil.rmtree(distdir)
        subprocess.check_call(
            ['tar', '-xf', args.dist_tar_file, '-C', workdir])
        shutil.move(os.path.join(workdir, 'dist'), distdir)
        subprocess.check_call(['npm', 'publish', dryrun, '--tag', args.tag])

    print('\n\n========== Publish unstripped package ==========')
    with PackageConfigPatcher('unstripped'):
        if os.path.exists(distdir):
            shutil.rmtree(distdir)
        subprocess.check_call(
            ['tar', '-xf', args.dist_tar_file, '-C', workdir])
        shutil.move(os.path.join(workdir, 'dist.unstripped'), distdir)
        subprocess.check_call(
            ['npm', 'publish', dryrun, '--tag', args.tag + '-unstripped'])

    shutil.rmtree(workdir)


if __name__ == '__main__':
    main()

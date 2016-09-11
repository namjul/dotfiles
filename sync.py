#!/usr/bin/env python

"""
Dotfiles syncronization.
Makes symlinks for all files: ./tilde/bashrc.bash will by available as ~/.bashrc.
Based: https://gist.github.com/490016
Source: https://github.com/denysdovhan/dotfiles/blob/master/sync.py
"""

import os
import sys
import glob
import shutil

# Get first, second an third arguments
arg1 = sys.argv[1] if 1 < len(sys.argv) else None
arg2 = sys.argv[2] if 2 < len(sys.argv) else None
arg3 = sys.argv[3] if 3 < len(sys.argv) else None

DOTFILES_DIR  = os.path.dirname(os.path.abspath(__file__))
SOURCE_DIR    = os.path.join(DOTFILES_DIR, arg1 or 'tilde')
DEST_DIR      = arg2 or os.path.expanduser('~')

# Excluded files
EXCLUDE = []

# Files without dots
NO_DOT_PREFIX = [
    'autoload',
    'backups',
    'bundle',
    'spell',
    'swaps',
    'undo'
]

# Files which should be left with extentions
PRESERVE_EXTENSION = []


def force_remove(path):
	if os.path.isdir(path) and not os.path.islink(path):
		shutil.rmtree(path, False)
	else:
		os.unlink(path)


def is_link_to(link, dest):
	is_link = os.path.islink(link)
	is_link = is_link and os.readlink(link).rstrip('/') == dest.rstrip('/')
	return is_link


def main():
	os.chdir(SOURCE_DIR)
	for filename in [file for file in glob.glob('*') if file not in EXCLUDE]:
		dotfile = filename
		if filename not in NO_DOT_PREFIX:
			dotfile = '.' + dotfile
		if filename not in PRESERVE_EXTENSION:
			dotfile = os.path.splitext(dotfile)[0]
		dotfile = os.path.join(DEST_DIR, dotfile)
		source = os.path.join(SOURCE_DIR, filename).replace('~', '.')

		# Check that we aren't overwriting anything
		if os.path.lexists(dotfile):
			if is_link_to(dotfile, source):
				continue

			response = raw_input("Overwrite file `%s'? [y/N] " % dotfile)
			if not response.lower().startswith('y'):
				print "Skipping `%s'..." % dotfile
				continue

			force_remove(dotfile)

                print source
                print dotfile
		os.symlink(source, dotfile)
		print "%s => %s" % (dotfile, source)


if __name__ == '__main__':
	main()

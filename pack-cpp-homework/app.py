import argparse
import os
import sys
import zipfile
from pathlib import Path

parser = argparse.ArgumentParser(prog='pack-cpp-hw')
parser.add_argument('path', nargs='*', default=os.getcwd())
args = parser.parse_args()

def pack_dir(dir_path):
    base_dir = Path(dir_path).resolve()
    if not base_dir.exists():
        raise FileNotFoundError(base_dir)
    output_file = base_dir / 'homework.zip'
    print(f'writing {output_file}')
    with zipfile.ZipFile(output_file, 'w') as output:
        dir = base_dir
        for ext in ('*.cpp', '*.h'):
            for source in dir.glob(ext):
                relative_path = source.relative_to(base_dir)
                print('\t', relative_path)
                output.write(source, relative_path)
    print(f'complete {output_file}')


if __name__ == '__main__':
    pack_dir(args.path)

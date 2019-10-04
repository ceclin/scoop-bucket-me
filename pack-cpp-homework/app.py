import argparse
import os
import sys
import zipfile
from pathlib import Path

parser = argparse.ArgumentParser(prog='pack-cpp-hw')
parser.add_argument('path', nargs='*', default=os.getcwd())
parser.add_argument('--name', '-n', dest='name',
                    default=os.environ.get('CPP_HOMEWORK_NAME', 'unknown'))
parser.add_argument('--student-number', '-sn', dest='student_number',
                    default=os.environ.get('CPP_HOMEWORK_STUDENT_NUMBER', 'unknown'))
parser.add_argument('--homework-version', '-hv',
                    dest='homework_version', type=int, default=1)
args = parser.parse_args()

name = args.name
student_number = args.student_number
homework_version = args.homework_version


def pack_dir(dir_path):
    base_dir = Path(dir_path).resolve()
    if not base_dir.exists():
        raise FileNotFoundError(base_dir)
    target_dirs = [x for x in base_dir.glob('Q*') if x.is_dir()]
    if len(target_dirs) == 0:
        print('no target found')
        return
    if homework_version > 0:
        output_file = base_dir / \
            f'{student_number}_{name}_hw{base_dir.name}_v{homework_version}.zip'
    else:
        output_file = base_dir / \
            f'{student_number}_{name}_hw{base_dir.name}.zip'
    print(f'writing {output_file}')
    with zipfile.ZipFile(output_file, 'w') as output:
        for dir in target_dirs:
            for ext in ('*.cpp', '*.h'):
                for source in dir.glob(ext):
                    relative_path = source.relative_to(base_dir)
                    print('\t', relative_path)
                    output.write(source, relative_path)
    print(f'complete {output_file}')


if __name__ == '__main__':
    pack_dir(args.path)

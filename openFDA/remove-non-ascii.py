import sys, os
import codecs
import re

class InputException(Exception):
    def handle(self):
        print self.message

def main():
    file_to_read = read_user_input()
    data = import_data(file_to_read)
    output_file = file_to_read.replace('.txt', '') + '-data.txt'
    with open(output_file, 'w') as f:
        f.write(re.sub(r'[^\x00-\x7f]',r' ', data))

def read_user_input():
    '''
    Read the user-specified input, terminate if none is provided.
    '''
    args = sys.argv
    if len(args) != 2:
        raise InputException(
            '\nError on argparse, exactly one file should be specified.'
            '\nUsage: "python remove-non-ascii.py [file]"'
        )
    return args[1]

def import_data(file_to_read):
    '''
    Takes the file read in 'read_user_input', makes sure the file exists and imports it.
    Raises an exception if the file cannot be read or cannot be found.
    Returns the file
    '''
    if not os.path.isfile(file_to_read):
        raise InputException(
            '\nError on file import, could not find the file.'
            '\nUsage: "python remove-non-ascii.py [file]"'
        )
    try:
        f = codecs.open(file_to_read, encoding='utf-8')
        data = f.read()
        f.close()
        return data
    except:
        raise InputException(
            '\nError on file import, could not read the file.'
            '\nUsage: "python remove-non-ascii.py [file]"'
        )

if __name__ == '__main__': main()

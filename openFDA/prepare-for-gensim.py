'''
Script for converting documents in a user-specified directory
to lowercase, removing stopwords, removes non-ascii chars, and splits lines.

1. Optionally, remove words that occur only once in the document
   With a word of caution: depending on domain, words that occur once may be important.

Writes results to a document where each line is a separate sentence with punctuation removed

Example usage:
####for doc in drugInteractionsFolder/*; do python refine.py $doc >> OUTPUT.txt; done
python prepare-for-gensim.py drugInteractionsFolder/
'''

class InputException(Exception):
    def handle(self):
        print self.message

try:
    import sys, os, glob
    import codecs
    import unicodedata
    import re
    import string

    import nltk
    # 153 stopwords from the nltk corpus
    from nltk.corpus import stopwords
except:
    raise InputException(
        '\nError on import, make sure all packages are installed correctly.'
    )

def main():
    SECTION_NUMBER = re.compile(r'\d\.\d')
    ALPHANUM = re.compile(r'[^a-z0-9 ]')
    dir_to_read = read_user_input()
    OUTPUT = 'drug-words.txt'
    #data = import_data(file_to_read)
    #output_file = file_to_read.replace('.txt', '') + '-data.txt'
    current = 1
    total = len(os.listdir(dir_to_read))
    for file in os.listdir(dir_to_read):
        print "%s: %s / %s" % (file, current, total)
        file = dir_to_read + file #"drugInteractionsFolder/Omeprazole.txt"
        data = import_data(file)
        current_section = 1
        total_sections = len(data.splitlines())
        for line in data.splitlines():
            print "Document %s/%s | Section %s/%s" % (current, total, current_section, total_sections)
            #convert from unicode to string
            data_string = unicodedata.normalize('NFKD', data).encode('ascii','ignore')
            #remove section numbers
            data_string = SECTION_NUMBER.sub('', data_string)
            #convert all text to lowercase
            data_string = data_string.lower()
            #remove digits
            data_string = ' '.join([word for word in nltk.word_tokenize(data_string) if (not word.isdigit())])
            #remove all non-lowercase characters
            data_string = ALPHANUM.sub('', data_string)
            #remove stopwords
            data_string = filter_stopwords(data_string)
            
            #update numbers
            current_section = current_section + 1

            with open(OUTPUT, 'a') as f:
                f.write(data_string)
            f.close()

def read_user_input():
    '''
    Read the user-specified input, terminate if none is provided.
    Succeeds if there are two args and the directory exists
    '''
    args = sys.argv
    if len(args) != 2:
        raise InputException(
            '\nError on argparse, exactly one file should be specified.'
            '\nUsage: "python prepare-for-gensim.py [dir]"'
        )
    if not os.path.isdir(args[1]):
        raise InputException(
            '\nError on file import, could not find the directory, or directory is invalid.'
            '\nUsage: "python prepare-for-gensim.py [dir]"'
        )
    return args[1]

def import_data(file_to_read):
    '''
    Reads the contents of a file 'file_to_read', makes sure it is real before reading contents
    Raises an exception if the file cannot be read or cannot be found.
    Returns the file as a string
    '''
    try:
        f = codecs.open(file_to_read, encoding='utf-8')
        data = f.read()
        f.close()
        return data
    except:
        raise InputException(
            '\nError on file import, could not read the file.'
            '\nUsage: "python prepare-for-gensim.py [dir]"'
        )


def filter_stopwords(string_of_words):
    '''
    Takes a series of words as a string,
    returns the string of words with stopwords removed
    '''
    word_list = string_of_words.split()
    filtered_words = [word for word in word_list if word not in stopwords.words('english')]
    fixed_word_string =  ' '.join(filtered_words)
    return fixed_word_string

def remove_non_ascii(string_of_words):
    # The easier way is done above: unicodedata.normalize('NFKD', data).encode('ascii','ignore')
    '''
    Takes a string of words and removes non-ascii characters
    returns the string without the ascii characters
    '''
    return re.sub(r'[^\x00-\x7f]',r' ', string_of_words)

if __name__ == '__main__': main()

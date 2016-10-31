import random, string
import shutil
import sys
import StringIO

def random_word(source_alpha,length):
    return ''.join(random.choice(source_alpha) for i in range(length))

def cat(filename):
    buf = StringIO.StringIO()
    with open(filename,'r') as f:
        buf.seek(0)
        shutil.copyfileobj(f,buf)
    return buf.getvalue()
    
class FilterModule(object):
    ''' OpenShift Logging Filters '''

    def filters(self):
        return {
            'random_word': random_word,
            'cat': cat
        }

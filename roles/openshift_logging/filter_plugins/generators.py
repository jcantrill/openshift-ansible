import random, string

def random_word(source_alpha,length):
    return ''.join(random.choice(source_alpha) for i in range(length))

class FilterModule(object):
    ''' OpenShift Logging Filters '''

    def filters(self):
        return {
            'random_word': random_word
        }

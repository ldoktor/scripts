#!/usr/bin/env python
# -*- coding: utf8 -*-
"""
This script takes words as input, finds translation using StarDict (sdcv)
and prints the output in given order suitable for (not only) Anki import.

Config:
You might need to adjust the "PROFILE" and "CONVERT" variables of this file.
Current version translates from English to English and Czech:
$english    $english_explanation    $czech

Preprocess:
In case you have CSV file with words, just use
cat $file | xargs -d ',' -n 1 | $this_script.py

My usual workflow:
1. read a book using 'cool reader' on Android phone
2. double-click unknown word and translate using Fora dictionary (can be set
   as default action on double-click)
3. once a while open Fora -> export -> All History as list (*.txt)
4. run sdcv2anki.py -i $sdcard/fora-exported/all_history.txt -o output.tsv
5. start Anki -> Import -> plain text files & select the output.tsv
6. set the separating character, enable HTML, enable update notes and fields
7. press import and verify it was successful

update EN_CS dict here http://slovnik.zcu.cz/online/index.php
"""
from optparse import OptionParser
import re
import subprocess
import sys


#: PROFILE: Output profile. It records translation for each group of dicts
#:          separated by ';'. Each group can define multiple dictionaries
#:          separated by ',' and the first match is used.
PROFILE = (u"WordNet,OxfordGlossary,LongmanGlossary;"
           u"GNU/FDL Anglicko-Český slovník,EN_CS")
#: CONVERT: Dict of chars which needs to be replaced
CONVERT = {'\n': '<br>', '\t': '  '}


class IncompleteError(ValueError):
    """ Raised in case of incomplete translation """
    pass


class MultiDict(object):
    """
    Stores multiple words from multiple dictionaries into single object.
    """
    def __init__(self, out):
        self.storage = {}
        self._parse_output(out)

    def _parse_output(self, out):
        """
        Parse output of sdcv
        """
        look_for_dictionary = True
        dictionary = None
        word = None
        translation = []
        for line in out.splitlines():
            if line.startswith('-->'):
                if look_for_dictionary:
                    if translation and word and dictionary:
                        self.add(word, dictionary,
                                      "\n".join(translation))
                    dictionary = line[3:].strip()
                    look_for_dictionary = False
                else:
                    word = line[3:].strip()
                    look_for_dictionary = True
                    translation = []
            else:
                line = line.strip()
                if line:
                    translation.append(line)
        if translation and word and dictionary:
            self.add(word, dictionary, "\n".join(translation))

    def add(self, word, dictionary, translation):
        """ Stores the given translation into word->dictionary """
        if word not in self.storage:
            self.storage[word] = {}
        self.storage[word][dictionary] = translation

    def str_words(self):
        """
        :return: all stored words
        """
        return ", ".join(self.storage.keys())

    def __getitem__(self, word):
        return self.storage[word]

    def __contains__(self, word):
        return word in self.storage


class SDCVTranslator(object):
    """
    Star dict console version translator
    """
    def __init__(self, profile):
        """
        :param profile: list of lists of dictionary names to use for translation
        :param partial: partial translations (None=ask, True=use, False=skip)
        """
        self._profile = profile
        self.warnings = []

    def try_translate(self, word, partial=None):
        """
        Interactive version which translates the word
        """
        original = word
        while True:
            try:
                translation = self.translate(word, partial)
                break
            except IncompleteError, details:
                sys.stderr.write("%s\nPress enter to use partial translation, "
                                 "'s' to skip this word or write another word "
                                 "to use instead of this one: " % details)
                _input = raw_input()
                if not _input:
                    partial = True
                elif _input == 's':
                    self.warnings.append("SKIP: %s" % original)
                    return
                else:
                    word = _input
            except ValueError, details:
                sys.stderr.write("%s\nChose another word or press enter to "
                                 "skip this one: " % details)
                word = raw_input()
                if not word:
                    return
        if word != original:
            self.warnings.append("MOD : %s->%s" % (original, word))
        return translation

    def translate(self, word, partial=None):
        """
        Single translation
        """
        sdcv = subprocess.Popen("sdcv -n '%s'" % word, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, shell=True)
        out = sdcv.stdout.read()
        if not out:
            raise ValueError("Error while translating word '%s', stderr:\n%s"
                             % (word, sdcv.stderr.read()))
        multidict = MultiDict(out)
        if word not in multidict:
            raise ValueError("Word '%s' not in dictionary, similar words: '%s'"
                             % (word, multidict.str_words()))

        return self.format(word, multidict, partial)

    def format(self, word, multidict, partial=None):
        """
        Format the output acording to self._profile
        """
        translation = [word]
        err = []
        for fmts in self._profile:
            for fmt in fmts:
                if fmt in multidict[word]:
                    translation.append(multidict[word][fmt])
                    break
            else:
                translation.append('')  # No translation for given _profile
                err.append(fmts)
        if err:
            if partial is None:     # Not set, ask user
                raise IncompleteError("Translation of '%s' not available in "
                                      "'%s', similar words are '%s'"
                                      % (word, err, multidict.str_words()))
            elif partial is False:  # Skip this word
                return None
            else:
                self.warnings.append("PART: %s" % word)
        return translation


class Output(object):
    """
    Formats the output to suit our needs
    """
    def __init__(self, convert=None):
        def compile_convert(replace):
            """ Prepare regexp for converting the output """
            replace = dict((re.escape(k), v) for k, v in replace.iteritems())
            pattern = re.compile("|".join(replace.keys()))
            return pattern, replace
        self._words = []
        self._convert = compile_convert(convert)

    def convert(self, text):
        """ Replace string which needs to be converted """
        fce = lambda _: self._convert[1][re.escape(_.group(0))]
        return self._convert[0].sub(fce, text)


    def add(self, word):
        """ Add record """
        self._words.append([self.convert(_) for _ in word])

    def to_tsv(self):
        """ Format output as tsv """
        return "\n".join(["\t".join(word) for word in self._words])


class SDCV2Anki(object):
    """ cmdline script for StarDict -> Anki conversion """
    def __init__(self):
        def parse_profile(profile):
            """ Parse string to list of lists """
            profiles = profile.split(';')
            return tuple(_.split(',') for _ in profiles)

        self.input = None
        self.output = None
        self.debug = None
        self.partial = None

        _ = ("This script takes words as input, finds translation using "
             "StarDict (sdcv) and prints the output in given order suitable "
             "for (not only) Anki import.")
        parser = OptionParser(description=_)
        parser.add_option('-i', '--in_file', dest='input', help="input file "
                          "containing '\\n' separated words")
        parser.add_option('-o', '--out_file', dest='output', help="output file")
        parser.add_option('-p', '--partial', dest='partial', help="allow "
                          "partial translation (by default asks)",
                          action="store_true")
        parser.add_option('-n', '--no-partial', dest='partial', help="disable "
                          "partial translation (by default asks)",
                          action="store_false")
        parser.add_option('-d', '--debug', dest='debug', action="store_true",
                          help="enable additional logging (to stderr)")
        parser.add_option('-P', '--profile', dest='profile', help="Override "
                          "default profile.")
        parser.add_option('-l', '--list-dictionaries', dest='list', help="List"
                          " available dictionaries", action='store_true')
        options = parser.parse_args()[0]
        if options.list:
            subprocess.Popen('sdcv -l', shell=True)
            sys.exit(3)
        if options.input:
            self.input = open(options.input, 'r').xreadlines()
        else:
            self.input = None
        if options.output:
            self.output = open(options.output, 'w')
        else:
            self.output = None
        if options.debug:
            self.debug = sys.stderr.write
        else:
            self.debug = lambda *args: None
        self.partial = options.partial
        self.profile = parse_profile(options.profile or PROFILE)


    def __iter__(self):
        return self

    def next(self):
        """ Get next word (from file or user) """
        if self.input:
            word = self.input.next()
        else:
            sys.stderr.write("Insert a word or press enter to exit: ")
            word = raw_input()
            if word == '':
                raise StopIteration()
        return word

    def run(self):
        """ run the main loop """
        translator = SDCVTranslator(self.profile)
        output = Output(CONVERT)
        for word in self:
            word = word.strip()
            if word:
                self.debug("ADD : %s\n" % word)
                translation = translator.try_translate(word, self.partial)
                if translation:
                    output.add(translation)

        if self.output:
            self.output.write(output.to_tsv())
        else:
            print output.to_tsv()

        if translator.warnings:
            self.debug("--< Warnings >--\n")
            self.debug("\n".join(translator.warnings))
            self.debug("\n")


if __name__ == '__main__':
    APP = SDCV2Anki()
    APP.run()
